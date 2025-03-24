# Zeal-Chatbot

This Chatbot App is a SwiftUI-based application that leverages Natural Language Processing (NLP), OpenAI's GPT-4.0 mini API, and efficient caching mechanisms to help users discover restaurants based on various criteria such as cuisine, location, and popular dishes. It intelligently processes real-world, messy JSON data to extract relevant details and provide fast, accurate, and personalized recommendations.

---

## Technologies Used

### Frontend

- SwiftUI – Used for building the user interface and managing dynamic content updates.

- MVVM Architecture – Ensures a clean separation of concerns between UI, business logic, and data management.

### Data Processing & Management

- Natural Language Processing (NLP) – Used on-device (lightweight) NLP library – NaturalLanguage to extract relevant details (e.g., cuisine, popular dishes) from multiple fields in the JSON dataset.

- JSON Parsing – Reads and processes raw JSON data into structured restaurant information.

- Hashing & Caching – Implements caching to store processed restaurant data for faster retrieval and to avoid unnecessary recomputation.

### 🔍 AI-Powered Search

- OpenAI GPT-4.0 mini API – Used for processing user queries and extracting key search parameters (e.g., location, dish, cuisine).

- Prompt Engineering – Used a carefully crafted prompt help extract structured keywords from user input for precise search matching.

---

## 📁 Project Structure

```
Zeal Chatbot/
│── ContentView.swift               # Main UI layer built with SwiftUI
│── RestaurantRepository.swift      # Handles JSON parsing, data extraction, caching
│── RestaurantViewModel.swift       # Manages restaurant data and business logic
│── AIService.swift                 # Calls OpenAI API for user query processing
│── Restaurant.swift                # Defines the restaurant struct
│── 100_restaurant_data.json/                         # Contains restaurant data
```

---

## 🏗 Core Features

### 1️⃣ Smart Restaurant Data Processing

- Parses and processes a messy JSON dataset containing restaurant details.

- Extracts missing or implicit cuisine types using NLP from various fields:

  1. Restaurant name

  2. Reviews mentioning cuisines

  3. Explicit cuisine fields (if available)

  4. Endorsements or metadata

  5. Identifies popular dishes using the same NLP-based approach.

### 2️⃣ AI-Powered Query Interpretation

- Uses GPT-4.0 mini API to analyze user queries.

- Extracts structured keywords: location, cuisine, dish, etc.

- Allows flexible queries like:

  1. "Find me the best sushi places in San Francisco"

  2. "Best Italian restaurants serving pasta in New York"

### 3️⃣ Efficient Caching for Instant Results

- Implements hashing and caching to store processed restaurant data.

- If restaurant data changes, triggers fresh computation and processing of restaurant data.

- Ensures low-latency results without repeated processing.

### 4️⃣ User-Friendly UI with SwiftUI

- Displays detailed restaurant cards with:

- Name, rating, location, cuisine, popular dishes.

- Smooth animations and SwiftUI state management for dynamic updates.

---

## 🔧 Installation & Setup

### Prerequisites

- macOS with Xcode installed

- Swift 5+

- OpenAI API key for GPT-4.0 mini integration

### Steps

1. Clone the repository:
```
  git clone https://github.com/Arnav3094/Zeal-Chatbot.git
  cd Zeal-Chatbot
```

2. Open the project in Xcode.

3. Create a `config.plist` file in the target folder.

4. Add your OpenAI API key to AIService.swift:
   
   <img width="549" alt="Screenshot 2025-03-25 at 12 00 24 AM" src="https://github.com/user-attachments/assets/08c93ea2-4c10-4692-9bda-dbefc184777b" />

6. Run the app on the iOS simulator or a real device.

Note: The app will require some time to process the data when you open the application for the first time. After the initial processing, enjoy **blazing fast querying**.


