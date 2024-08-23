//
//  LocationRouter.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/19/24.
//

import Foundation
import CoreLocation
import UIKit
import Combine
import SwiftUI

class LocationRouter: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = LocationRouter()
    private let locationHandler = CLLocationManager()
    private let settingsModel = SettingsModel.shared
    private var cancellable: AnyCancellable?
    
    @Published var location: CLLocationCoordinate2D?
    @Published var loading = false
    @Published var permissionsDenied = false
    @Published var weatherData: WeatherResponseBody?

    @AppStorage("lastLatitude") private var lastLatitude: Double?
    @AppStorage("lastLongitude") private var lastLongitude: Double?
    
    override init() {
        super.init()
        locationHandler.delegate = self
        locationHandler.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorizationStatus()

        // Subscribe to settingsChanged notification
        cancellable = NotificationCenter.default.publisher(for: .settingsChanged)
            .sink { [weak self] _ in
                self?.handleSettingsChanged()
            }
    }
    
    func checkLocationAuthorizationStatus() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationHandler.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            fetchLocation()
            permissionsDenied = false
        case .denied, .restricted:
            permissionsDenied = true
        default:
            permissionsDenied = true
        }
    }
    
    private func fetchLocation() {
        loading = true
        locationHandler.requestLocation()
    }

    func checkForLocation() {
        fetchLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first?.coordinate {
            DispatchQueue.main.async {
                if self.locationHasChanged(newLocation: currentLocation) {
                    self.location = currentLocation
                    self.updateStoredLocation(currentLocation)
                    self.fetchWeather(for: currentLocation)
                } else {
                    self.location = currentLocation
                }
                self.loading = false
            }
        }
    }
    
    private func locationHasChanged(newLocation: CLLocationCoordinate2D) -> Bool {
        guard let lastLat = lastLatitude, let lastLong = lastLongitude else {
            return true
        }
        return lastLat != newLocation.latitude || lastLong != newLocation.longitude
    }
    
    private func updateStoredLocation(_ location: CLLocationCoordinate2D) {
        lastLatitude = location.latitude
        lastLongitude = location.longitude
    }
    
    func fetchWeather(for location: CLLocationCoordinate2D) {
        Task {
            do {
                let fetchedWeatherData = try await WeatherUtility().fetchWeather(using: .coordinates(latitude: location.latitude, longitude: location.longitude))
                DispatchQueue.main.async {
                    self.weatherData = fetchedWeatherData
                }
            } catch {
                print("Failed to fetch weather: \(error)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch location:", error)
        DispatchQueue.main.async {
            self.loading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorizationStatus()
    }
    
    private func handleSettingsChanged() {
        // Handle the settings change, e.g., refetch the location or weather based on the new settings.
        fetchLocation()
    }
    
    deinit {
        cancellable?.cancel() // Ensure to cancel any running subscriptions
    }
}


//class LocationRouter: NSObject, CLLocationManagerDelegate, ObservableObject {
//    static let shared = LocationRouter()
//    private let locationHandler = CLLocationManager()
//    private let settingsModel = SettingsModel.shared
//    
//    @Published var location: CLLocationCoordinate2D?
//    @Published var loading = false
//    @Published var permissionsDenied = false
//    @Published var weatherData: WeatherResponseBody?
//
//    @AppStorage("lastLatitude") private var lastLatitude: Double?
//    @AppStorage("lastLongitude") private var lastLongitude: Double?
//    
//    override init() {
//        super.init()
//        locationHandler.delegate = self
//        locationHandler.desiredAccuracy = kCLLocationAccuracyBest
//        checkLocationAuthorizationStatus()
//    }
//    
//    func checkLocationAuthorizationStatus() {
//        let status = CLLocationManager.authorizationStatus()
//        switch status {
//        case .notDetermined:
//            locationHandler.requestWhenInUseAuthorization()
//        case .authorizedWhenInUse, .authorizedAlways:
//            fetchLocation()
//            permissionsDenied = false
//        case .denied, .restricted:
//            permissionsDenied = true
//        default:
//            permissionsDenied = true
//        }
//    }
//    
//    private func fetchLocation() {
//        loading = true
//        locationHandler.requestLocation()
//    }
//
//    func checkForLocation() {
//        fetchLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let currentLocation = locations.first?.coordinate {
//            DispatchQueue.main.async {
//                if self.locationHasChanged(newLocation: currentLocation) {
//                    self.location = currentLocation
//                    self.updateStoredLocation(currentLocation)
//                    self.fetchWeather(for: currentLocation)
//                } else {
//                    self.location = currentLocation
//                }
//                self.loading = false
//            }
//        }
//    }
//    
//    private func locationHasChanged(newLocation: CLLocationCoordinate2D) -> Bool {
//        guard let lastLat = lastLatitude, let lastLong = lastLongitude else {
//            return true
//        }
//        return lastLat != newLocation.latitude || lastLong != newLocation.longitude
//    }
//    
//    private func updateStoredLocation(_ location: CLLocationCoordinate2D) {
//        lastLatitude = location.latitude
//        lastLongitude = location.longitude
//    }
//    
//     func fetchWeather(for location: CLLocationCoordinate2D) {
//        Task {
//            do {
//                let fetchedWeatherData = try await WeatherUtility().fetchWeather(using: .coordinates(latitude: location.latitude, longitude: location.longitude))
//                DispatchQueue.main.async {
//                    self.weatherData = fetchedWeatherData
//                }
//            } catch {
//                print("Failed to fetch weather: \(error)")
//            }
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Failed to fetch location:", error)
//        DispatchQueue.main.async {
//            self.loading = false
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        checkLocationAuthorizationStatus()
//    }
//}
