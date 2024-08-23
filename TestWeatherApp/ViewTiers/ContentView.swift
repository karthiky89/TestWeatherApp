//
//  ContentView.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/19/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationHandler = LocationRouter() /// TODO : Make this singleton
    @StateObject var weatherUtil = WeatherUtility()
    @State private var searchText = ""
    @StateObject var settingModel = SettingsModel.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if let location = locationHandler.location {
                    if let weatherData = locationHandler.weatherData {
                        SecondTierView(weatherApiResponse: weatherData)
                    } else {
                        TransitioningView()
                    }
                } else {
                    if locationHandler.loading {
                        TransitioningView()
                    } else {
                        TopTierView()
                            .environmentObject(locationHandler)
                    }
                }
            }
            .background(Color(hue: 0.663, saturation: 0.904, brightness: 0.739))
            .preferredColorScheme(.dark)
            .toolbar {
                if !locationHandler.loading {
                    ToolbarItem(placement: .navigationBarLeading) {
                        SearchToolView(
                            isShowingSearchOptions: .constant(false),
                            isLoading: locationHandler.loading, // This should be false since we want the toolbar when not loading
                            onSearch: performSearch
                        )
                    }
                }
            }
        }
        .onAppear {
            if locationHandler.location == nil && !locationHandler.loading {
                locationHandler.checkLocationAuthorizationStatus()
            }
        }
    }
    
    // Function to compare the current location with the last saved location
    
    func performSearch(searchText: String) {
        guard !searchText.isEmpty else {
            print("Search input is empty")
            return
        }

        Task {
            do {
                let weatherResponse: WeatherResponseBody
                
                // Check if the searchText is a ZIP code (numeric only)
                if searchText.allSatisfy(\.isNumber) {
                    weatherResponse = try await weatherUtil.fetchWeather(using: .location(cityName: searchText, stateCode: nil, countryCode: "US"))
                } else {
                    // Treat as a city name query
                    weatherResponse = try await weatherUtil.fetchWeather(using: .location(cityName: searchText, stateCode: nil, countryCode: nil))
                }

                locationHandler.weatherData = weatherResponse
                self.searchText = ""
            } catch {
                print("Error fetching weather: \(error)")
            }
        }
    }


}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



