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
    /// Formats the `Double` value to a string with zero decimal places.
    /// - Returns: A string representation of the `Double`, rounded to the nearest whole number.
    func formattedAsInteger() -> String {
        String(format: "%.0f", self)
    }
}

// MARK: - Int Extension

/// Extension for converting an `Int` value to pressure in inches of mercury (inHg).
extension Int {
    /// Converts the integer value to pressure in inches of mercury (inHg).
    /// - Returns: A string representation of the pressure, formatted to two decimal places.
    var pressureInInHg: String {
        let inHg = Double(self) * 0.02953
        return String(format: "%.2f", inHg)
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

// MARK: - Date Extension

/// Extension for working with `Date` objects.
extension Date {
    /// Creates a `Date` object from a Unix timestamp.
    /// - Parameter timestamp: The Unix timestamp.
    /// - Returns: A `Date` object representing the given timestamp.
    static func fromUnixTimestamp(_ timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    /// Formats the date to a string showing only the hour and minute.
    /// - Returns: A string representation of the time in the format "hh:mm".
    func formattedTime() -> String {
        return self.formatted(.dateTime.hour().minute())
    }
    
    /// Converts a timezone offset (in seconds) to a formatted local time string.
    /// - Parameter offsetInSeconds: The timezone offset in seconds.
    /// - Returns: A string representation of the local time adjusted by the given offset.
    func localTimeString(fromOffset offsetInSeconds: Int) -> String {
        let timeZone = TimeZone(secondsFromGMT: offsetInSeconds)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
}

// MARK: - URL Extension

/// Extension for generating URLs related to weather icons.
extension URL {
    /// Constructs a URL for a weather icon based on the icon code.
    /// - Parameter iconCode: The code representing the weather icon.
    /// - Returns: A `URL` pointing to the weather icon image.
    func iconURL(for iconCode: String) -> URL? {
        let baseURL = "https://openweathermap.org/img/wn/"
        let size = "@2x.png" // Use @2x for high resolution
        return URL(string: "\(baseURL)\(iconCode)\(size)")
    }
}
