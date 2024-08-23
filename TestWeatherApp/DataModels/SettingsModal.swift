//
//  SettingsModal.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/22/24.
//

import Foundation
import SwiftUI
import Combine


class SettingsModel: ObservableObject {
    @AppStorage("isMetric") var isMetric: Bool = false // Default: Celsius
    @AppStorage("useApiGeocoding") var useApiGeocoding: Bool = false // Default: iOS
    @AppStorage("isGeocoderEnabled") var isGeocoderEnabled: Bool = true // Default: ON

    static let shared = SettingsModel()
    
    func currentSettingsSnapshot() -> (isMetric: Bool, useApiGeocoding: Bool, isGeocoderEnabled: Bool) {
        return (isMetric, useApiGeocoding, isGeocoderEnabled)
    }
}

