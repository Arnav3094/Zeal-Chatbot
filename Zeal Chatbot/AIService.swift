//
//  AIService.swift
//  Zeal Assignment
//
//  Created by Arnav Mangla on 24/03/25.
//

import Foundation

final class AIService {
    static let shared = AIService()
    
    private var key: String
    
    private init() {
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let config = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
              let apiKey = config["OPENAI_KEY"] as? String else {
            print("❌ API Key not found")
            fatalError("API Key not found")
        }
        key = apiKey
    }
    
    public func getResponse(input: String) async throws ->(dish: String?, cuisine: String?, location: String?) {
        // Creating the URL
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        var request = URLRequest(url: url)
        
        // Setting HTTP header fields
        request.httpMethod = "POST"
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct request body
        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "Extract 'dish', 'cuisine', and 'location' (city or two-letter state) from the query. 'Dish' must be a specific dish (not a cuisine), 'cuisine' must be a cuisine (not a dish). 'Location' must be either a city or a two-letter state code, never both. Return a JSON object with keys: 'dish', 'cuisine', 'location'."],
                ["role": "user", "content": input]
            ],
            "max_tokens": 48,
            "temperature": 0.5
        ]
        
        // Adding the parameters to the request body
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        print("request: \(request)")
        print("request.httpBody: \(String(describing: request.httpBody))")
        print("request.httpMethod: \(String(describing: request.httpMethod))")
        
        // Perform the network request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate the HTTP response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let httpResponse = response as? HTTPURLResponse
            print("Response: \(String(describing: response))")
            print("status code: \(String(describing: httpResponse?.statusCode))")
            throw NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
        }
        
        // Extracting JSON string from API response
        guard let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = jsonResponse["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let textResponse = message["content"] as? String
        else {
            print("❌ Failed to parse response")
            let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let choices = jsonResponse?["choices"] as? [[String: Any]]
            let firstChoice = choices?.first
            let message = firstChoice?["message"] as? [String: Any]
            let textResponse = message?["content"] as? String
            
            print("jsonResponse: \(String(describing: jsonResponse))")
            print("choices: \(String(describing: choices))")
            print("firstChoice: \(String(describing: firstChoice))")
            print("message: \(String(describing: message))")
            print("textResponse: \(String(describing: textResponse))")
            
            throw NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        print("textResponse: \(textResponse)")
        
        // Ensure response is a valid JSON string and parse it
        guard let jsonData = textResponse.data(using: .utf8) else {
            print("❌ Invalid JSON format in AI response")
            let jsonData = textResponse.data(using: .utf8)
            print("json data content as string: \(jsonData ?? Data())")
            throw NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format in AI response"])
        }
        
        guard let extractedInfo = try? JSONDecoder().decode(ExtractedInfo.self, from: jsonData) else {
            print("❌ Invalid JSON structure")
            throw NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
        }
        
        print("extractedInfo: \(extractedInfo)")
        return (dish: extractedInfo.dish, cuisine: extractedInfo.cuisine, location: extractedInfo.location)
        
    }
}
                               
struct ExtractedInfo: Codable {
    let dish: String?
    let cuisine: String?
    let location: String?
}
