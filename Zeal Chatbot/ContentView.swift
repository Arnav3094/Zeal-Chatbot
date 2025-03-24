//
//  ContentView.swift
//  Zeal Chatbot
//
//  Created by Arnav Mangla on 24/03/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RestaurantViewModel()
    
    @State private var searchQuery = ""
    @State private var isSearching = false
    @State private var showAlert = false
    
    @State private var searchButtonText = "Search"
    
    var body: some View {
        VStack {
            Text("Zeal AI ChatBot")
                .font(.title)
                .padding(.top)
                .padding(.horizontal)
            
            Text("An AI-powered restaurant hunting solution")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            

            TextField("Enter your query...", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
                .overlay(
                    HStack{
                        Spacer()
                        Button(action: {
                            searchQuery = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 20)
                    }
                )

            Button(searchButtonText) {
                Task {
                    searchButtonText = "Searching..."
                    isSearching = true
                    await viewModel.searchRestaurants(query: searchQuery)
                    isSearching = false
                    searchButtonText = "Search"
                    
                    if viewModel.errorMessage != nil {
                        showAlert = true
                    }
                }
            }
            .disabled(isSearching)
            .padding()
            
            if viewModel.searchResults.count > 0 {
                Text("Found \(viewModel.searchResults.count) restaurants")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            List(viewModel.searchResults, id: \.id) { restaurant in
                VStack(alignment: .leading) {
                    HStack {
                        Text(restaurant.name).font(.headline)
                        Spacer()
                        if let rating = restaurant.rating {
                            Text("⭐ \(formatNumber(rating, to: 1))")
                                .font(.subheadline) +
                            Text(" /5")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("Unrated")
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                    }
                    if let city = restaurant.city, let state = restaurant.state {
                    Text("\(city), \(state)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                    
                    if restaurant.cuisines.count > 0 {
                        let cuisines: [String] = restaurant.cuisines
                        HStack {
                            Text("Cuisine:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ForEach(cuisines, id: \.self) { cuisine in
                                Text(cuisine)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    if restaurant.popular_dishes.count > 0 {
                        let popularDishes: [String] = restaurant.popular_dishes
                        HStack {
                            Text("Popular Dishes:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ForEach(popularDishes, id: \.self) { dish in
                                Text(dish)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }

                    }
                }
                .padding(12)
                .padding(.horizontal, 5)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage!), dismissButton: .default(Text("OK")))
        }
        .onAppear{
            Task {
                await viewModel.loadRestaurants()
            }
        }
    }
}

func formatNumber(_ number: Double, to decimalPlaces: Int) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = decimalPlaces
    formatter.maximumFractionDigits = decimalPlaces
    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
}

#Preview {
    ContentView()
}
