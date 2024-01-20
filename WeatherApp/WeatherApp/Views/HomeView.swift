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
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                if let weather = weather {
                    Text("Weather data fetched")
                }
                else {
                    LoadingView()
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                            } catch {
                                print("Error getting weather information.")
                            }
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
        .onAppear {
            zipToLatLong(zipCode: "43081")
        }
        .padding()
        .preferredColorScheme(.dark)
    }
    
    func zipToLatLong(zipCode: String) {
        LocationManager.getCoordinate(from: zipCode) { coordinate in
            if let coordinate = coordinate {
                print("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
            } else {
                //TODO: catch this as error
                print("Unable to get coordinates for the provided zip code.")
            }
        }
    }
}

#Preview {
    HomeView()
}
