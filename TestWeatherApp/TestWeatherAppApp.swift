//
//  TestWeatherAppApp.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/19/24.
//

import SwiftUI

@main
struct TestWeatherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    

    var body: some Scene {
        WindowGroup {
            WeatherContainerView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("App will enter foreground")
        // Perform any additional actions here
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App did enter background")
        // Perform any additional actions here
    }
}
