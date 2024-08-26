//
//  WeatherUtility.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/19/24.
//

import Foundation
import Combine
import CoreLocation

// Enum to represent the different query types
enum WeatherQuery {
    case coordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    case location(cityName: String, stateCode: String?, countryCode: String?)
}

/// A utility class for fetching weather and geocoding information.
class WeatherUtility: ObservableObject {
    private var cancellable: AnyCancellable?
    
    private var settingsModel: SettingsModel {
        SettingsModel.shared
    }
    
    /// The API key used for requests to the weather service.
    /// TODO : move this key fetch to secure approch.
    private static let apiKey = "7eb073775018aa85cc958bfa0afe842c"

    /// Fetches weather data based on the specified query.
    /// - Parameter query: The type of query (coordinates or location).
    /// - Returns: The weather data for the given query.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    func fetchWeather(using query: WeatherQuery) async throws -> WeatherResponseBody {
        let units = settingsModel.isMetric ? "metric" : "imperial"
        let urlString: String
        
        switch query {
        case .coordinates(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(Self.apiKey)&units=\(units)"
            
        case .location(let cityName, let stateCode, let countryCode):
            if cityName.allSatisfy(\.isNumber) {
                // Use cityName as ZIP code
                let zipCode = cityName
                let coordinatesResponse = try await fetchCoordinatesForZip(zip: zipCode, countryCode: countryCode ?? "US")
                urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinatesResponse.lat)&lon=\(coordinatesResponse.lon)&appid=\(Self.apiKey)&units=\(units)"
            } else {
                // Treat cityName as a city name
                var locationQuery = cityName
                if let state = stateCode {
                    locationQuery += ",\(state)"
                }
                if let country = countryCode {
                    locationQuery += ",\(country)"
                }
                urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(locationQuery)&appid=\(Self.apiKey)&units=\(units)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherResponseBody.self, from: data)
    }

    /// Fetches geocoding data (latitude and longitude) for a given city name, state, and country.
    /// - Parameters:
    ///   - cityName: The city name.
    ///   - stateCode: Optional state code.
    ///   - countryCode: Optional country code.
    ///   - limit: The maximum number of results to return.
    /// - Returns: An array of geocoding results.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    func fetchCoordinates(for cityName: String, stateCode: String? = nil, countryCode: String? = nil, limit: Int = 1) async throws -> [GeocodingResponse] {
        var query = "\(cityName)"
        if let state = stateCode {
            query += ",\(state)"
        }
        if let country = countryCode {
            query += ",\(country)"
        }
        
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(query)&limit=\(limit)&appid=\(Self.apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([GeocodingResponse].self, from: data)
    }

    /// Fetches geocoding data for a given ZIP code.
    /// - Parameters:
    ///   - zip: The ZIP code.
    ///   - countryCode: The country code.
    /// - Returns: The geocoding data for the ZIP code.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    func fetchCoordinatesForZip(zip: String, countryCode: String) async throws -> ZipCodeResponse {
        let urlString = "https://api.openweathermap.org/geo/1.0/zip?zip=\(zip),\(countryCode)&appid=\(Self.apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ZipCodeResponse.self, from: data)
    }

    /// Fetches coordinates based on a query string, using either API or Apple’s Geocoder based on settings.
    /// - Parameters:
    ///   - query: The query string for location (city name or ZIP code).
    ///   - completion: A closure that is called with the resulting coordinates or `nil` if an error occurs.
    func fetchCoordinates(for query: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        if settingsModel.isGeocoderEnabled {
            if settingsModel.useApiGeocoding {
                Task {
                    do {
                        let response = try await fetchCoordinates(for: query)
                        if let firstResult = response.first {
                            completion(CLLocationCoordinate2D(latitude: firstResult.lat, longitude: firstResult.lon))
                        } else {
                            completion(nil)
                        }
                    } catch {
                        print("Error fetching coordinates from API: \(error)")
                        completion(nil)
                    }
                }
            } else {
                fetchCoordinatesUsingAppleGeocoder(for: query, completion: completion)
            }
        } else {
            Task {
                do {
                    let response = try await fetchCoordinates(for: query)
                    if let firstResult = response.first {
                        completion(CLLocationCoordinate2D(latitude: firstResult.lat, longitude: firstResult.lon))
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("Error fetching coordinates from API: \(error)")
                    completion(nil)
                }
            }
        }
    }

    /// Fetches coordinates using Apple’s Geocoder.
    /// - Parameters:
    ///   - query: The query string for location.
    ///   - completion: A closure that is called with the resulting coordinates or `nil` if an error occurs.
    func fetchCoordinatesUsingAppleGeocoder(for query: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error)")
                completion(nil)
            } else if let placemark = placemarks?.first, let location = placemark.location {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }

    deinit {
        cancellable?.cancel() // Ensure any active subscriptions are cancelled.
    }
}
