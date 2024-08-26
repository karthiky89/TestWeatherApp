import SwiftUI

import SwiftUI

//struct SettingsTierView: View {
//    @ObservedObject var settingsModel: SettingsModel
//    @State private var originalSettings: SettingsModel
//    @Environment(\.presentationMode) var presentationMode // To dismiss the view
//    
//    init(settingsModel: SettingsModel) {
//        self.settingsModel = settingsModel
//        _originalSettings = State(initialValue: settingsModel) // Track initial settings
//    }
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Settings")) {
//                    HStack {
//                        Text("Metrics")
//                        Spacer()
//                        Toggle(isOn: $settingsModel.isMetric) {
//                            Text(settingsModel.isMetric ? "Celsius" : "Fahrenheit")
//                        }
//                    }
//                    
//                    HStack {
//                        Text("GeoCoding via")
//                        Spacer()
//                        Toggle(isOn: $settingsModel.useApiGeocoding) {
//                            Text(settingsModel.useApiGeocoding ? "API" : "iOS")
//                        }
//                    }
//                    
//                    HStack {
//                        Text("Geocoder")
//                        Spacer()
//                        Toggle(isOn: $settingsModel.isGeocoderEnabled) {
//                            Text(settingsModel.isGeocoderEnabled ? "ON" : "OFF")
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Settings")
//            .navigationBarItems(trailing: Button("Close") {
//                if settingsModel != originalSettings {
//                    // Post notification if settings have changed
//                    NotificationCenter.default.post(name: .settingsChanged, object: nil)
//                }
//                // Dismiss view
//                presentationMode.wrappedValue.dismiss()
//            })
//        }
//    }
//}
//
//extension Notification.Name {
//    static let settingsChanged = Notification.Name("settingsChanged")
//}
//
//// Make sure SettingsModel conforms to Equatable
//extension SettingsModel: Equatable {
//    static func == (lhs: SettingsModel, rhs: SettingsModel) -> Bool {
//        return lhs.isMetric == rhs.isMetric &&
//               lhs.useApiGeocoding == rhs.useApiGeocoding &&
//               lhs.isGeocoderEnabled == rhs.isGeocoderEnabled
//    }
//}
//

import SwiftUI


struct SettingsTierView: View {
    @ObservedObject var settingsModel: SettingsModel
    @State private var originalSettings: (isMetric: Bool, useApiGeocoding: Bool, isGeocoderEnabled: Bool)
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var showProgress = false
    
    init(settingsModel: SettingsModel) {
        self.settingsModel = settingsModel
        _originalSettings = State(initialValue: settingsModel.currentSettingsSnapshot())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Settings")) {
                        HStack {
                            Text("Metrics")
                            Spacer()
                            Toggle(isOn: $settingsModel.isMetric) {
                                Text(settingsModel.isMetric ? "Celsius" : "Fahrenheit")
                            }
                        }
                        
                        HStack {
                            Text("GeoCoding via")
                            Spacer()
                            Toggle(isOn: $settingsModel.useApiGeocoding) {
                                Text(settingsModel.useApiGeocoding ? "API" : "iOS")
                            }
                        }
                        
                        HStack {
                            Text("Geocoder")
                            Spacer()
                            Toggle(isOn: $settingsModel.isGeocoderEnabled) {
                                Text(settingsModel.isGeocoderEnabled ? "ON" : "OFF")
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarItems(trailing: Button("Close") {
                    let currentSettings = settingsModel.currentSettingsSnapshot()
                    if currentSettings != originalSettings {
                        showingAlert = true
                    } else {
                        // Dismiss view if no settings have changed
                        presentationMode.wrappedValue.dismiss()
                    }
                    // Post notification if settings have changed
                    NotificationCenter.default.post(name: .settingsChanged, object: nil)
                })
                
                if showProgress {
                    ProgressView("Updating settings...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .background(Color.clear.opacity(0.8))
                        .cornerRadius(10)
                        .padding(20)
                        .transition(.opacity)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Re-Configuring"),
                    message: Text("Updating settings will reset weather to your current location."),
                    dismissButton: .default(Text("OK")) {
                        // Start showing progress view after alert dismiss
                        DispatchQueue.main.async {
                            showProgress = true
                            startTimer()
                        }
                    }
                )
            }
        }
    }
    
    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showProgress = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}




extension Notification.Name {
    static let settingsChanged = Notification.Name("settingsChanged")
}

