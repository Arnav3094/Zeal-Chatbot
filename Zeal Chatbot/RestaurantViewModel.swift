//
//  RestaurantViewModel.swift
//  Zeal Assignment
//
//  Created by Arnav Mangla on 24/03/25.
//

import Foundation
import Combine

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var searchResults: [Restaurant] = []
    @Published var errorMessage: String?
    
    private let repository: RestaurantRepository
    private let aiService: AIService
    
    init(repository: RestaurantRepository = RestaurantRepository(), aiService: AIService = .shared) {
        self.repository = repository
        self.aiService = aiService
    }
    
    // Ensures that the UI updates are performed on the main thread
    @MainActor
    func loadRestaurants() async {
        do {
            restaurants = try await repository.loadRestaurants()
        } catch {
            print("❌ Error loading restaurants: \(error)")
        }
    }
    
    // Ensures that the UI updates are performed on the main thread
    @MainActor
    func searchRestaurants(query: String) async {
        print("searchRestaurants: \(query)")
        
        do{
            let (dish, cuisine, location) = try await aiService.getResponse(input: query)
            searchResults = filterRestaurants(dish: dish, cuisine: cuisine, location: location)
        } catch {
            print("❌ Error searching restaurants: \(error)")
            errorMessage = "Error searching restaurants: \(error.localizedDescription)"
        }
        
        // sorting the search results by rating
        searchResults.sort(by: { ($0.rating ?? 0) > ($1.rating ?? 0) })
    }
    
    private func filterRestaurants(dish: String?, cuisine: String?, location: String?) -> [Restaurant] {
        return restaurants.filter{ restaurant in
            let matchesDish = dish == nil || restaurant.popular_dishes.contains(where: {$0.lowercased().contains(dish!.lowercased())})
            let matchesCuisine = cuisine == nil || restaurant.cuisines.contains(where: {$0.lowercased().contains(cuisine!.lowercased())})
            let matchesLocation = location == nil || ((restaurant.city?.lowercased().contains(location!.lowercased())) == true) || ((restaurant.state?.lowercased().contains(location!.lowercased())) == true)
            return matchesDish && matchesCuisine && matchesLocation
        }
    }
}
