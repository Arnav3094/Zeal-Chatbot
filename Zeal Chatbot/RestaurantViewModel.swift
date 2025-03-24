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
        do {
            try self.aiService.setup()
        } catch (let error) {
            errorMessage = "Error setting up AI Service: \(error.localizedDescription)"
        }
        
    }
    
    func loadRestaurants() async {
        do {
            restaurants = try await repository.loadRestaurants()
        } catch {
            print("❌ Error loading restaurants: \(error)")
        }
    }
    
    func searchRestaurants(query: String) async {
        do{
            let (dish, cuisine, location) = try await aiService.getResponse(input: query)
            searchResults = filterRestaurants(dish: dish, cuisine: cuisine, location: location)
        } catch {
            print("❌ Error searching restaurants: \(error)")
            errorMessage = "Error searching restaurants: \(error.localizedDescription)"
        }
    }
    
    private func filterRestaurants(dish: String?, cuisine: String?, location: String?) -> [Restaurant] {
        restaurants.filter{ restaurant in
            let matchesDish = dish == nil || restaurant.popular_dishes.contains(where: {$0.lowercased().contains(dish!.lowercased())})
            let matchesCuisine = cuisine == nil || restaurant.cuisines.contains(where: {$0.lowercased().contains(cuisine!.lowercased())})
            let matchesLocation = location == nil || ((restaurant.city?.lowercased().contains(location!.lowercased())) == true) || ((restaurant.state?.lowercased().contains(location!.lowercased())) == true)
            return matchesDish && matchesCuisine && matchesLocation
        }
    }
}
