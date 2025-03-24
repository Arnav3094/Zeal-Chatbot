//
//  Restaurant.swift
//  Zeal Chatbot
//
//  Created by Arnav Mangla on 24/03/25.
//


struct Restaurant: Codable, Identifiable {
    let id: Int
    let name: String
    let city: String?
    let state: String?
    let country: String?
    let street_address: String?
    let zip_code: String?
    let phone_number: String?
    var cuisines: [String]
    var popular_dishes: [String]
    let rating: Double?
    let image_url: String?
    let restaurant_url: String?
    let latitude: Double?
    let longitude: Double?
    
    // Additional fields
    let featured_in: [String]?
    let description: String?
    let tags: [String]?
    let endorsement_copy: String?

    // Computed Properties for Full-Text Search
    var searchableText: String {
        """
        \(name.lowercased())
        \(featured_in?.joined(separator: " ").lowercased() ?? "")
        \(description?.lowercased() ?? "")
        \(endorsement_copy?.lowercased() ?? "")
        \(tags?.joined(separator: " ").lowercased() ?? "")
        \(cuisines.joined(separator: " ").lowercased())
        \(popular_dishes.joined(separator: " ").lowercased())
        """
    }
}