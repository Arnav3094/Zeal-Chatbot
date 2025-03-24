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
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search restaurants...", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        Task {
                            isSearching = true
                            await viewModel.searchRestaurants(query: searchQuery)
                            isSearching = false
                            if viewModel.errorMessage != nil {
                                showAlert = true
                            }
                        }
                    }
                
                if isSearching {
                    ProgressView()
                } else {
                    List(viewModel.searchResults) { restaurant in
                        VStack(alignment: .leading) {
                            Text(restaurant.name)
                                .font(.headline)
                            Text(restaurant.cuisines.joined(separator: ", "))
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Restaurant Search")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage!), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            Task {
                await viewModel.loadRestaurants()
            }
        }
    }
}

#Preview {
    ContentView()
}
