//
//  IconGrabberView.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/21/24.
//

import SwiftUI

struct IconGrabberView: View {
    let iconCode: String

    var body: some View {
        if let url = iconURL(for: iconCode) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100) // Adjust size as needed
                
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(systemName: "questionmark") // Fallback icon
        }
    }
}

func iconURL(for iconCode: String) -> URL? {
    let baseURL = "https://openweathermap.org/img/wn/"
    let size = "@2x.png" // Use @2x for high resolution
    return URL(string: "\(baseURL)\(iconCode)\(size)")
}
