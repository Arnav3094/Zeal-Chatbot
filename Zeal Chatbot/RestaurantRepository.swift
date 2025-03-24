//
//  RestaurantRepository.swift
//  Zeal Assignment
//
//  Created by Arnav Mangla on 24/03/25.
//

import Foundation

struct RestaurantRepository{
    
    /// Loads the restaurant data from the JSON file, extracting cuisines and dishes from multiple fields.
    /// - Returns: An array of `Restaurant` objects with enhanced keyword extraction.
    func loadRestaurants() async throws -> [Restaurant] {
        guard let url = Bundle.main.url(forResource: "100_restaurant_data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load JSON")
            throw NSError(domain: "RestaurantRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load JSON"])
        }

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
                let state = (json["state"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                let country = json["country"] as? String
                let street_address = json["street_address"] as? String
                let zip_code = json["zip_code"] as? String
                let phone_number = json["phone_number"] as? String
                let rating = json["rating"] as? Double
                let image_url = json["image_url"] as? String
                let restaurant_url = json["restaurant_url"] as? String
                let latitude = json["latitude"] as? Double
                let longitude = json["longitude"] as? Double
                let description = json["description"] as? String
                let endorsement_copy = json["endorsement_copy"] as? String

                // Extract cuisines
                var cuisines = Set<String>()
                if let cuisineList = json["cuisines"] as? [String] {
                    cuisines.formUnion(cuisineList.map { $0.lowercased() })
                }
                if let endorsement = endorsement_copy {
                    cuisines.formUnion(extractCuisines(from: endorsement))
                }
                if let desc = description {
                    cuisines.formUnion(extractCuisines(from: desc))
                }
                if let tags = json["tags"] as? [String] {
                    cuisines.formUnion(tags.map { $0.lowercased() })
                }

                // Extract popular dishes
                var popularDishes = Set<String>()
                if let dishList = json["popular_dishes"] as? [String] {
                    popularDishes.formUnion(dishList.map { $0.lowercased() })
                }
                if let endorsement = endorsement_copy {
                    popularDishes.formUnion(extractDishes(from: endorsement))
                }
                if let desc = description {
                    popularDishes.formUnion(extractDishes(from: desc))
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
                    cuisines: Array(cuisines),
                    popular_dishes: Array(popularDishes),
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

                restaurants.append(restaurant)
            }

            print("✅ Successfully processed \(restaurants.count) restaurants with enhanced cuisine & dish extraction")
            return restaurants
        } catch {
            print("❌ JSON Decoding Error: \(error)")
            return []
        }
    }

    /// Extracts cuisine names from a given text using keyword matching.
    private func extractCuisines(from text: String) -> Set<String> {
        let knownCuisines: Set<String> = ["italian", "chinese", "mexican", "indian", "thai", "japanese", "french", "mediterranean", "korean"]
        let words = Set(text.lowercased().split(separator: " ").map{ String($0) })
        return words.intersection(knownCuisines)
    }

    /// Extracts dish names from a given text using keyword matching.
    private func extractDishes(from text: String) -> Set<String> {
        let knownDishes: Set<String> = ["pizza", "burger", "pasta", "sushi", "tacos", "ramen", "biryani", "steak", "pancakes"]
        let words = Set(text.lowercased().split(separator: " ").map{ String($0) })
        return words.intersection(knownDishes)
    }

    
}

