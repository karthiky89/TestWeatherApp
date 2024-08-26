//
//  TopTierView.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/19/24.
//

import SwiftUI
import CoreLocationUI

struct TopTierView: View {
    @EnvironmentObject var locationHandler: LocationRouter
    
    var body: some View {
        VStack {
            Text("Weather App")
                .bold().font(.title)
            Text("A JPMC Code Challenge")
                .bold().font(.subheadline)
            
            if locationHandler.loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 50, height: 50)
            } else if locationHandler.location == nil {
                if locationHandler.permissionsDenied {
                    Text("Location permissions are denied. Please enable location services in settings.")
                        .padding(10.0)
                        .bold().font(.body)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Please Share your location to fetch Accurate Weather")
                        .padding(10.0)
                        .bold().font(.body)
                        .multilineTextAlignment(.center)
                    LocationButton(.shareCurrentLocation) {
                        locationHandler.checkLocationAuthorizationStatus()
                    }
                    .cornerRadius(20.0)
                    .symbolVariant(.slash)
                    .foregroundColor(.black)
                    .padding(10.0)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Always attempt to fetch location on appear
            locationHandler.checkLocationAuthorizationStatus()
        }
    }
}

