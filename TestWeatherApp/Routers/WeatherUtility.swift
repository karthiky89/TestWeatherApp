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

class WeatherUtility: ObservableObject {
    private var cancellable: AnyCancellable?
    
    private var settingsModel: SettingsModel {
        SettingsModel.shared
    }
    
    func fetchWeather(using query: WeatherQuery) async throws -> WeatherResponseBody {
        let apiKey = "7eb073775018aa85cc958bfa0afe842c"
        let units = settingsModel.isMetric ? "metric" : "imperial"
        
        let urlString: String
        
        switch query {
        case .coordinates(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)"
            
        case .location(let cityName, let stateCode, let countryCode):
            // Check if cityName is numeric (indicating a ZIP code)
            if cityName.allSatisfy(\.isNumber) {
                // Use cityName as ZIP code
                let zipCode = cityName
                let coordinatesResponse = try await fetchCoordinatesForZip(zip: zipCode, countryCode: countryCode ?? "US")
                let latitude = coordinatesResponse.lat
                let longitude = coordinatesResponse.lon
                urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)"
            } else {
                // Treat as city name
                var locationQuery = cityName
                if let state = stateCode {
                    locationQuery += ",\(state)"
                }
                if let country = countryCode {
                    locationQuery += ",\(country)"
                }
                urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(locationQuery)&appid=\(apiKey)&units=\(units)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let responseBody = try JSONDecoder().decode(WeatherResponseBody.self, from: data)
        
        return responseBody
    }

    // Function to fetch coordinates using city name, state, and country
    func fetchCoordinates(for cityName: String, stateCode: String? = nil, countryCode: String? = nil, limit: Int = 1) async throws -> [GeocodingResponse] {
        let apiKey = "7eb073775018aa85cc958bfa0afe842c"
        var query = "\(cityName)"
        if let state = stateCode {
            query += ",\(state)"
        }
        if let country = countryCode {
            query += ",\(country)"
        }
        
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(query)&limit=\(limit)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode([GeocodingResponse].self, from: data)
        
        return response
    }

    
    // Function to fetch coordinates by zip code
    func fetchCoordinatesForZip(zip: String, countryCode: String) async throws -> ZipCodeResponse {
        let apiKey = "7eb073775018aa85cc958bfa0afe842c"
        let urlString = "https://api.openweathermap.org/geo/1.0/zip?zip=\(zip),\(countryCode)&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let zipCodeResponse = try JSONDecoder().decode(ZipCodeResponse.self, from: data)
        
        return zipCodeResponse
    }

    // Function to fetch coordinates based on settings
    func fetchCoordinates(for query: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        if settingsModel.isGeocoderEnabled {
            if settingsModel.useApiGeocoding {
                Task {
                    do {
                        let response = try await fetchCoordinates(for: query)
                        if let firstResult = response.first {
                            let coordinate = CLLocationCoordinate2D(latitude: firstResult.lat, longitude: firstResult.lon)
                            completion(coordinate)
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
            // Direct API call for geocoding if geocoder is disabled
            Task {
                do {
                    let response = try await fetchCoordinates(for: query)
                    if let firstResult = response.first {
                        let coordinate = CLLocationCoordinate2D(latitude: firstResult.lat, longitude: firstResult.lon)
                        completion(coordinate)
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

    
    // Function to fetch coordinates using Apple's Geocoder
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
        cancellable?.cancel() // Ensure to cancel any running subscriptions
    }
}


//// Response struct for the Weather API
//struct WeatherResponseBody: Decodable {
//    var coord: CoordinatesResponse
//    var weather: [WeatherResponse]
//    var base: String
//    var main: MainResponse
//    var visibility: Int
//    var wind: WindResponse
//    var clouds: CloudsResponse
//    var dt: Int
//    var sys: SysResponse
//    var timezone: Int
//    var id: Int
//    var name: String
//    var cod: Int
//
//    struct CoordinatesResponse: Decodable {
//        var lon: Double
//        var lat: Double
//    }
//
//    struct WeatherResponse: Decodable {
//        var id: Int
//        var main: String
//        var description: String
//        var icon: String
//    }
//
//    struct MainResponse: Decodable {
//        var temp: Double
//        var feels_like: Double
//        var temp_min: Double
//        var temp_max: Double
//        var pressure: Int
//        var humidity: Int
//        var sea_level: Int?
//        var grnd_level: Int?
//    }
//    
//    struct WindResponse: Decodable {
//        var speed: Double
//        var deg: Int
//        var gust: Double?
//    }
//    
//    struct CloudsResponse: Decodable {
//        var all: Int
//    }
//    
//    struct SysResponse: Decodable {
//        var type: Int?
//        var id: Int?
//        var country: String
//        var sunrise: Int
//        var sunset: Int
//    }
//}
//
//extension WeatherResponseBody.MainResponse {
//    var feelsLike: Double { return feels_like }
//    var tempMin: Double { return temp_min }
//    var tempMax: Double { return temp_max }
//}
//
//
//
//// Response struct for the geocoding API
//struct GeocodingResponse: Codable {
//    let name: String
//    let localNames: [String: String]?
//    let lat: Double
//    let lon: Double
//    let country: String
//    let state: String?
//
//    enum CodingKeys: String, CodingKey {
//        case name
//        case localNames = "local_names"
//        case lat
//        case lon
//        case country
//        case state
//    }
//}
//
//
//// Response struct for the zip code API
//struct ZipCodeResponse: Decodable {
//    let zip: String
//    let name: String
//    let lat: CLLocationDegrees
//    let lon: CLLocationDegrees
//    let country: String
//}
