//
//  RestaurantRepository.swift
//  Zeal Assignment
//
//  Created by Arnav Mangla on 24/03/25.
//

import Foundation
import CryptoKit
import NaturalLanguage

struct RestaurantRepository{
    
    private let hashKey: String = "restaurant_data"
    private let cachedDataKey: String = "cached_restaurant_data"
    
    /// Loads the restaurant data by computing from the JSON file, only recomputing if the hash changes, otherwise returning the cached data.
    /// - Returns: An array of `Restaurant` objects with enhanced keyword extraction.
    func loadRestaurants() async throws -> [Restaurant] {
        guard let url = Bundle.main.url(forResource: "100_restaurant_data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load JSON")
            throw NSError(domain: "RestaurantRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load JSON"])
        }
        
        let currentHash = computeSHA256(for: data)
        let storedHash = UserDefaults.standard.string(forKey: hashKey)
        
        if let storedHash = storedHash, storedHash == currentHash,
           let cachedData = UserDefaults.standard.data(forKey: cachedDataKey),
           let cachedRestaurants = try? JSONDecoder().decode([Restaurant].self, from: cachedData),
           cachedRestaurants.count > 0{
            print("✅ Using cached restaurant data")
            print("cachedRestaurants.count: \(cachedRestaurants.count)")
            return cachedRestaurants
        }
        
        print("🔄 Hash changed or no cache found. Recomputing...")

        do {
            // Decode JSON as an array of dictionaries to process fields manually
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                print("❌ Invalid JSON format")
                return []
            }

            var restaurants: [Restaurant] = []

            for json in jsonArray {
                let id = json["id"] as? Int ?? -1
                let name = json["name"] as? String ?? "Unknown Restaurant"
                let city = (json["city"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                var state = (json["state"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                if state?.lowercased() == "california"{
                    state = "CA"
                }
                let country = json["country"] as? String
                let street_address = json["street_address"] as? String
                let zip_code = json["zip_code"] as? String
                let phone_number = json["phone_number"] as? String
                let rating = json["rating"] as? Double
                let image_url = json["image_url"] as? String
                let restaurant_url = json["restaurant_url"] as? String
                let latitude = json["latitude"] as? Double
                let longitude = json["longitude"] as? Double
                let description = (json["description"] as? String) ?? ""
                let endorsement_copy = (json["endorsement_copy"] as? String) ?? ""
                let cuisinesList = (json["cuisine_list"] as? String) ?? ""
                let tags = (json["tags"] as? String) ?? ""
                let reviews = (json["top_reviews"] as? [String]) ?? []

                // Proceed even if some values are empty
                let combinedText = [cuisinesList, endorsement_copy, description, tags].joined(separator: " ")
                let extractedCuisines = extractCuisines(from: combinedText)
                var extractedDishes = extractDishes(from: combinedText)

                // Process only positive reviews
                for review in reviews where analyzeSentiment(review) {
                    extractedDishes.append(contentsOf: extractDishes(from: review))
                }
                
                let restaurant = Restaurant(
                    id: id,
                    name: name,
                    city: city,
                    state: state,
                    country: country,
                    street_address: street_address,
                    zip_code: zip_code,
                    phone_number: phone_number,
                    cuisines: Array(Set(extractedCuisines)),
                    popular_dishes: Array(Set(extractedDishes)),
                    rating: rating,
                    image_url: image_url,
                    restaurant_url: restaurant_url,
                    latitude: latitude,
                    longitude: longitude,
                    featured_in: json["featured_in"] as? [String],
                    description: description,
                    tags: json["tags"] as? [String],
                    endorsement_copy: endorsement_copy
                )
                
                print("✅ Successfully processed restaurant: \(restaurant.name)")
                restaurants.append(restaurant)
                print("restaurants.count: \(restaurants.count)")

            }

            print("✅ Successfully processed \(restaurants.count) restaurants.")
            
            // Store the hash and cache the data
            UserDefaults.standard.set(currentHash, forKey: hashKey)
            if let cachedData = try? JSONEncoder().encode(restaurants) {
                UserDefaults.standard.set(cachedData, forKey: cachedDataKey)
            }
            
            return restaurants
        } catch {
            print("❌ JSON Decoding Error: \(error)")
            return []
        }
    }
    
    /// Computes the SHA-256 hash of the given data.
    private func computeSHA256(for data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    /// Extracts cuisine names from a given text using keyword matching.
    private func extractCuisines(from text: String) -> [String] {
        var matchedCuisines = [String]()
        
        let knownCuisines: Set<String> = ["italian", "chinese", "indian", "thai", "mexican", "japanese", "french", "greek", "mediterranean", "american", "korean", "spanish", "tapas", "vietnamese", "middle eastern", "turkish", "caribbean", "peruvian", "brazilian", "argentinian", "african", "moroccan", "ethiopian", "lebanese", "israeli", "german", "russian", "polish", "czech", "hungarian", "austrian", "swiss", "belgian", "dutch", "scandinavian", "irish", "british", "scottish", "welsh", "portuguese", "catalan", "basque", "australian", "new zealand", "polynesian", "hawaiian", "filipino", "malaysian", "indonesian", "singaporean", "taiwanese", "pakistani", "bangladeshi", "sri lankan", "nepalese", "tibetan", "afghan", "iranian", "iraqi", "syrian", "egyptian", "tunisian", "algerian", "nigerian", "kenyan", "ugandan", "ghanaian", "south african", "zimbabwean", "zambian", "australian", "new zealand", "polynesian", "hawaiian", "filipino", "malaysian", "indonesian", "singaporean", "taiwanese", "indian", "pakistani", "bangladeshi", "sri lankan", "nepalese", "tibetan", "afghan", "iranian", "iraqi", "syrian", "lebanese", "israeli", "turkish", "egyptian", "moroccan", "tunisian", "algerian", "nigerian", "ethiopian", "kenyan", "ugandan"]
        
        for cuisine in knownCuisines {
            if text.lowercased().contains(cuisine.lowercased()) {
                matchedCuisines.append(cuisine)
            } else if fuzzyMatch(text, cuisine) { // Fuzzy matching
                print("Fuzzy match found for \(cuisine)")
                matchedCuisines.append(cuisine)
            }
        }
        
        return Array(Set(matchedCuisines)) // Remove duplicates
    }

    /// Extracts dish names from a given text using keyword matching.
    private func extractDishes(from text: String) -> [String] {
        var matchedDishes = [String]()
        
        let knownDishes: Set<String> = ["pizza", "burger", "pasta", "sushi", "tacos", "ramen", "biryani", "steak", "pancakes", "chicken", "fish", "ice cream", "coffee", "tea", "donuts", "cappuccino", "cereal", "chocolate, cake"]
        
        for dish in knownDishes {
            if text.lowercased().contains(dish.lowercased()) {
                matchedDishes.append(dish)
            } else if fuzzyMatch(text, dish) {
                print("Fuzzy match found for \(dish)")
                matchedDishes.append(dish)
            }
        }
        
        return Array(Set(matchedDishes))
    }

    private func fuzzyMatch(_ text: String, _ keyword: String) -> Bool {
        let distance = levenshteinDistance(text.lowercased(), keyword.lowercased())
        return distance < 2 // Allow slight variations
    }

    private func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let aCount = a.count
        let bCount = b.count
        var matrix = [[Int]]()

        for i in 0...aCount {
            matrix.append(Array(repeating: 0, count: bCount + 1))
            matrix[i][0] = i
        }

        for j in 0...bCount {
            matrix[0][j] = j
        }

        for i in 1...aCount {
            for j in 1...bCount {
                if Array(a)[i - 1] == Array(b)[j - 1] {
                    matrix[i][j] = matrix[i - 1][j - 1]
                } else {
                    matrix[i][j] = min(matrix[i - 1][j - 1] + 1, // substitution
                                       min(matrix[i][j - 1] + 1, // insertion
                                           matrix[i - 1][j] + 1)) // deletion
                }
            }
        }

        return matrix[aCount][bCount]
    }

    /// Analyzes sentiment of the given text.
    private func analyzeSentiment(_ text: String) -> Bool {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let sentiment = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore).0
        
        if let sentimentScore = sentiment?.rawValue, let score = Double(sentimentScore) {
            return score > 0 // Consider positive sentiment
        }
        return false
    }
}
