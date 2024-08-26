//
//  DataParserModel.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/21/24.
//

import Foundation
import Combine
import CoreLocation

// Response struct for the Weather API
struct WeatherResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var base: String
    var main: MainResponse
    var visibility: Int
    var wind: WindResponse
    var clouds: CloudsResponse
    var dt: Int
    var sys: SysResponse
    var timezone: Int
    var id: Int
    var name: String
    var cod: Int

    struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }

    struct WeatherResponse: Decodable {
        var id: Int
        var main: String
        var description: String
        var icon: String
    }

    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Int
        var humidity: Int
        var sea_level: Int?
        var grnd_level: Int?
    }
    
    struct WindResponse: Decodable {
        var speed: Double
        var deg: Int
        var gust: Double?
    }
    
    struct CloudsResponse: Decodable {
        var all: Int
    }
    
    struct SysResponse: Decodable {
        var type: Int?
        var id: Int?
        var country: String
        var sunrise: Int
        var sunset: Int
    }
}

extension WeatherResponseBody.MainResponse {
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}



// Response struct for the geocoding API
struct GeocodingResponse: Codable {
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat
        case lon
        case country
        case state
    }
}


// Response struct for the zip code API
struct ZipCodeResponse: Decodable {
    let zip: String
    let name: String
    let lat: CLLocationDegrees
    let lon: CLLocationDegrees
    let country: String
}
