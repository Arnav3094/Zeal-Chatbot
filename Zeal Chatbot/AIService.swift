//
//  AIService.swift
//  Zeal Assignment
//
//  Created by Arnav Mangla on 24/03/25.
//

import Foundation
import OpenAISwift

final class AIService {
    static let shared = AIService()
    
    private var client: OpenAISwift?
    
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
        print("key: \(key)")
    }
    
    public func setup() throws{
        
        self.client = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(apiKey: key))
    }
    
    public func getResponse(input: String) async throws -> (dish: String?, cuisine: String?, location: String?) {
        
        let prompt = """
            Extract popular dishes, cuisine, and location (city/state) from the following query. Return in JSON format:
            Query: \(input)
            {
                "dish": "dish_name",
                "cuisine": "cuisine_name",
                "location": "city_or_state_name"
            }
            """
        
        let result = try await client?.sendCompletion(with: prompt)
        
        guard let jsonString = result?.choices?.first?.text,
              let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        let extracted = try JSONDecoder().decode(ExtractedInfo.self, from: jsonData)
        return (extracted.dish, extracted.cuisine, extracted.location)
    }
}
                               
struct ExtractedInfo: Codable {
    let dish: String?
    let cuisine: String?
    let location: String?
}
