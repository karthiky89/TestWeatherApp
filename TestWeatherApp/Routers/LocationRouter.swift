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


/// A class responsible for managing location updates and fetching weather data based on the current location.
/// It conforms to `CLLocationManagerDelegate` for handling location updates and `ObservableObject` for state management.
class LocationRouter: NSObject, CLLocationManagerDelegate, ObservableObject {
    /// Singleton instance of `LocationRouter` for shared access.
    static let shared = LocationRouter()

    private let locationHandler = CLLocationManager()  // Manages location-related activities.
    private let settingsModel = SettingsModel.shared  // Singleton instance for settings management.
    private var cancellable: AnyCancellable?  // Subscription to notifications for settings changes.

    /// Published property that holds the current location coordinates.
    @Published var location: CLLocationCoordinate2D?

    /// Published property indicating whether location fetching is in progress.
    @Published var loading = false

    /// Published property indicating whether location permissions are denied.
    @Published var permissionsDenied = false

    /// Published property that holds the weather data fetched based on the current location.
    @Published var weatherData: WeatherResponseBody?

    /// Stored property for the last latitude coordinate, persisted across app launches.
    @AppStorage("lastLatitude") private var lastLatitude: Double?

    /// Stored property for the last longitude coordinate, persisted across app launches.
    @AppStorage("lastLongitude") private var lastLongitude: Double?

    /// Initializes the `LocationRouter`, sets up location manager, and subscribes to settings changes.
    override init() {
        super.init()
        locationHandler.delegate = self
        locationHandler.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorizationStatus()

        // Subscribe to settingsChanged notification to handle settings updates.
        cancellable = NotificationCenter.default.publisher(for: .settingsChanged)
            .sink { [weak self] _ in
                self?.handleSettingsChanged()
            }
    }
    
    /// Checks the current location authorization status and requests authorization if needed.
    /// Updates the `permissionsDenied` property based on the authorization status.
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
    
    /// Requests the current location from the location manager and sets the `loading` property to true.
    private func fetchLocation() {
        loading = true
        locationHandler.requestLocation()
    }

    /// Triggers a location fetch.
    func checkForLocation() {
        fetchLocation()
    }

    /// Handles the update of locations from the location manager.
    /// - Parameter manager: The location manager that generated the update.
    /// - Parameter locations: An array of `CLLocation` objects containing the updated locations.
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
    
    /// Determines if the location has changed compared to the stored last location.
    /// - Parameter newLocation: The new location to compare against the stored location.
    /// - Returns: A boolean indicating whether the location has changed.
    private func locationHasChanged(newLocation: CLLocationCoordinate2D) -> Bool {
        guard let lastLat = lastLatitude, let lastLong = lastLongitude else {
            return true
        }
        return lastLat != newLocation.latitude || lastLong != newLocation.longitude
    }
    
    /// Updates the stored last location with the new location coordinates.
    /// - Parameter location: The new location coordinates to store.
    private func updateStoredLocation(_ location: CLLocationCoordinate2D) {
        lastLatitude = location.latitude
        lastLongitude = location.longitude
    }
    
    /// Fetches weather data based on the given location coordinates.
    /// - Parameter location: The location coordinates to use for fetching weather data.
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
    
    /// Handles errors that occur during location fetching.
    /// - Parameter manager: The location manager that encountered the error.
    /// - Parameter error: The error encountered while fetching location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch location:", error)
        DispatchQueue.main.async {
            self.loading = false
        }
    }
    
    /// Responds to changes in location authorization status.
    /// - Parameter manager: The location manager that observed the authorization change.
    /// - Parameter status: The new authorization status.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorizationStatus()
    }
    
    /// Handles changes in application settings, e.g., refetching location or weather based on new settings.
    private func handleSettingsChanged() {
        fetchLocation()
    }
    
    /// Cancels any active subscriptions when the `LocationRouter` instance is deinitialized.
    deinit {
        cancellable?.cancel() // Ensure to cancel any running subscriptions
    }
}
