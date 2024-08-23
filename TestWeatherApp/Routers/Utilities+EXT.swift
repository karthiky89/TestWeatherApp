//
//  Utilities+EXT.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/19/24.
//

import Foundation
import SwiftUI
import WebKit
import AVKit


// MARK: - Double Extension

/// Extension for formatting a `Double` value as a string with no decimal places.
extension Double {
    /// Formats the Double value to a string with zero decimal places.
    /// - Returns: A string representation of the Double rounded to the nearest whole number.
    func formattedAsInteger() -> String {
        String(format: "%.0f", self)
    }
}

extension Int {
    var pressureInInHg: String {
        let inHg = Double(self) * 0.02953
        return String(format: "%.2f ", inHg)
    }
}

// MARK: - View Extension

/// Extension for applying rounded corners to specific corners of a SwiftUI `View`.
extension View {
    /// Applies a corner radius to specific corners of the view.
    /// - Parameters:
    ///   - radius: The radius of the corner curve.
    ///   - corners: A `UIRectCorner` value specifying which corners should be rounded.
    /// - Returns: A view with the specified corners rounded.
    func applyCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

// MARK: - RoundedCornerShape

/// A shape that defines rounded corners for specific corners of a view.
struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    /// Creates a path defining the shape with rounded corners.
    /// - Parameter rect: The bounding rectangle in which the path is drawn.
    /// - Returns: A `Path` representing the shape with rounded corners.
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Date {
    static func fromUnixTimestamp(_ timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    func formattedTime() -> String {
        return self.formatted(.dateTime.hour().minute())
    }
}

extension URL{
    func iconURL(for iconCode: String) -> URL? {
        let baseURL = "https://openweathermap.org/img/wn/"
        let size = "@2x.png" // Use @2x for high resolution
        return URL(string: "\(baseURL)\(iconCode)\(size)")
    }
}




extension Date {
    // Converts a timezone offset (in seconds) to a formatted local time string
    func localTimeString(fromOffset offsetInSeconds: Int) -> String {
        // Create a TimeZone object with the given offset
        let timeZone = TimeZone(secondsFromGMT: offsetInSeconds)
        
        // Create a DateFormatter for formatting the local time
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        formatter.timeZone = timeZone
        
        // Return the formatted local time string
        return formatter.string(from: self)
    }
}


