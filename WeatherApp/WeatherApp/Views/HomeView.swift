//
//  HomeView.swift
//  WeatherApp
//
//  Created by Lindsey Olson on 1/20/24.
//

import CoreLocation
import CoreLocationUI
import SwiftUI

struct HomeView: View {
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State var forecast: ForecastBody?
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                if let weather = weather {
                    Text("\(weather.properties.relativeLocation.properties.city), \(weather.properties.relativeLocation.properties.state)")
                        .font(.title)
                    if let forecast = forecast {
                        Text("Today, the temperature is \(forecast.properties.updateTime)")
                    } else {
                        LoadingView()
                            .task {
                                forecast = await weatherManager.getForecast(url: weather.properties.forecast)
                            }
                    }
                } else {
                    LoadingView()
                        .task {
                            weather = await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                        }
                }
            }
            else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .preferredColorScheme(.dark)
    }
}

#Preview {
    HomeView()
}
