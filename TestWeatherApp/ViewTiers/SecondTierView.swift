//
//  SecondTierView.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/19/24.
//

import SwiftUI


struct SecondTierView: View {
    var weatherApiResponse: WeatherResponseBody
    
    @State private var isSheetExpanded: Bool = false
    @State private var offset: CGFloat = UIScreen.main.bounds.height * 0.6
    @State private var showSettingsSheet: Bool = false
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                // Main Content
                VStack(alignment: .leading, spacing: 5) {
                    Text(weatherApiResponse.name)
                        .bold()
                        .font(.title)
                    HStack {
                        let now = Date()
                                // Convert the timezone offset from the API response to a string (e.g., -18000)
                                let offsetInSeconds = weatherApiResponse.timezone
                                let localTimeString = now.localTimeString(fromOffset: offsetInSeconds)
                        Text("Today, \(localTimeString)")
                            .fontWeight(.light)
                        Spacer()
                        Text("Feels Like \((weatherApiResponse.main.feelsLike.formattedAsInteger() + "°"))")
                            .fontWeight(.light)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                VStack {
                    HStack {
                        VStack {
                            IconGrabberView(iconCode: weatherApiResponse.weather[0].icon)

                            Text("\(weatherApiResponse.weather[0].main)")
                                .offset(y: -20)
                        }
                        .frame(width: 135, alignment: .leading)
                        
                        Spacer()
                        
                        Text(weatherApiResponse.main.temp.formattedAsInteger() + "°")
                            .font(.system(size: 75))
                            .fontWeight(.bold)
                            .padding()
                            .frame(alignment: .trailing)
                    }
                    
                    Spacer()
                        .frame(height: 60)
                    
                    AsyncImage(url: URL(string: "https://cdn.pixabay.com/photo/2020/01/24/21/33/city-4791269_960_720.png")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 350)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Draggable and Tappable Half-Sheet
            GeometryReader { geometry in
                VStack {
                    HStack {
                        // Chevron Button (Leading)
                        Button(action: {
                            withAnimation(.smooth()) {
                                isSheetExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isSheetExpanded ? "chevron.down" : "chevron.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                                .foregroundColor(.black)
                        }
                        .padding(.leading, 20) // Add padding from the left
                        
                        Spacer()
                        
                        // Settings Button (Trailing)
                        Button(action: {
                            showSettingsSheet.toggle()
                        }) {
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, 20) // Add padding from the right
                    }
                    .padding(.top, 10) // Add padding from the top

                    // Weather Details Sheet
                    WeatherDetailsSheet(weatherApiResponse: weatherApiResponse)
                        .padding(.top, 0) // Remove top padding to align with the buttons
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .background(Color.white)
                .cornerRadius(20)
                .offset(y: isSheetExpanded ? 0 : geometry.size.height * 0.6)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            let screenHeight = geometry.size.height
                            let threshold = screenHeight * 0.3

                            withAnimation(.spring()) {
                                if -value.translation.height > threshold {
                                    isSheetExpanded = false // Collapse
                                } else if value.translation.height > threshold {
                                    isSheetExpanded = true // Expand
                                }
                            }
                        }
                )
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .sheet(isPresented: $showSettingsSheet) {
                SettingsTierView(settingsModel: SettingsModel.shared)
            }
        }
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
    }
}




struct WeatherDetailsSheet: View {
    var weatherApiResponse: WeatherResponseBody

    var body: some View {
        VStack(alignment: .listRowSeparatorLeading, spacing: 10) {
            VStack(alignment: .listRowSeparatorLeading) {
                VStack(alignment: .leading) {
                    Text("Temprature Variations")
                            .fontWeight(.semibold)
                    // Row 1: Min Temp, Max Temp
                    HStack {
                        WeatherDetailsViewComponent(
                            primaryLogo: "thermometer",
                            secondaryLogo: nil,
                            name: "Min Temp",
                            value: "\(weatherApiResponse.main.tempMin.formattedAsInteger())°"
                        )
                        Spacer()
                        WeatherDetailsViewComponent(
                            primaryLogo: "thermometer",
                            secondaryLogo: nil,
                            name: "Max Temp",
                            value: "\(weatherApiResponse.main.tempMax.formattedAsInteger())°"
                        )
                    }

                }
                VStack(alignment: .leading) {
                    Text("Winds")
                            .fontWeight(.semibold)
                    // Row 2: Wind Speed, Wind Temp (if available), Wind Gust (if available)
                    HStack {
                        WeatherDetailsViewComponent(
                            primaryLogo: "wind",
                            secondaryLogo: nil,
                            name: "Speed",
                            value: "\(weatherApiResponse.wind.speed.formattedAsInteger()) m/s"
                        )
                        Spacer()
                        // Wind Temp placeholder, assuming it might be represented by a different image
                        WeatherDetailsViewComponent(
                            primaryLogo: "thermometer",
                            secondaryLogo: nil,
                            name: "Temp",
                            value: "\(weatherApiResponse.main.temp.formattedAsInteger())°"
                        )
                    }
                    if let gust = weatherApiResponse.wind.gust {
                        VStack{
                            WeatherDetailsViewComponent(
                                primaryLogo: "wind",
                                secondaryLogo: "arrow.right.circle",
                                name: "Gust",
                                value: "\(gust.formattedAsInteger()) m/s"
                            )
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    // Row 3: Sunrise, Sunset
                    Text("Sunrise & Sunset")
                            .fontWeight(.semibold)
                    HStack {
                        WeatherDetailsViewComponent(
                            primaryLogo: "sunrise",
                            secondaryLogo: nil,
                            name: "Sunrise",
                            value: Date.fromUnixTimestamp(weatherApiResponse.sys.sunrise).formattedTime()
                        )
                        Spacer()
                        WeatherDetailsViewComponent(
                            primaryLogo: "sunset",
                            secondaryLogo: nil,
                            name: "Sunset",
                            value: Date.fromUnixTimestamp(weatherApiResponse.sys.sunset).formattedTime()
                        )
                    }}
                
                VStack(alignment: .leading) {
                    Text("Atmosphere")
                            .fontWeight(.semibold)
                    // Row 4: Pressure, Humidity
                    HStack {
                        WeatherDetailsViewComponent(
                            primaryLogo: "gauge",
                            secondaryLogo: nil,
                            name: "Pressure",
                            value: "\(weatherApiResponse.main.pressure) hPa"
                        )
                        Spacer()
                        WeatherDetailsViewComponent(
                            primaryLogo: "humidity",
                            secondaryLogo: nil,
                            name: "Humidity",
                            value: "\(weatherApiResponse.main.humidity)%"
                        )
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .padding()
    }
}
