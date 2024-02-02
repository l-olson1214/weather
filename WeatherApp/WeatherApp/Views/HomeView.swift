//
//  HomeView.swift
//  WeatherApp
//
//  Created by Lindsey Olson on 1/20/24.
//

import CoreLocation
import CoreLocationUI
import SwiftUI

enum WeatherSelection {
    case current
    case future
}

struct HomeView: View {
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State var forecast: ForecastBody?
    
    @State private var selection = WeatherSelection.current
    @State private var isSheetVisible = false
    @State private var selectedPeriod: ForecastBody.Properties.Period? = nil
    @State private var currentTemp = 50
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                if let weather = weather {
                    locationInfo(weather)
                    if forecast != nil {
                        weatherPicker
                    } else {
                        LoadingView()
                            .task {
                                await fetchForecast(url: weather.properties.forecast)
                            }
                    }
                } else {
                    LoadingView()
                        .task {
                            await fetchWeather(location: location)
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
    
    private func heroImage() -> some View {
        GeometryReader { geometry in
            let imageName: String = {
                switch Chilliness(intValue: currentTemp) {
                case .reallyCold:
                    return "reallyCold"
                case .cold:
                    return "cold"
                case .chilly:
                    return "chilly"
                case .mild:
                    return "mild"
                case .warm:
                    return "warm"
                case .hot:
                    return "hot"
                case .none:
                    return "cloud"
                }
            }()
            
            return Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height / 3)
                .clipped()
        }
    }
    
    func fetchWeather(location: CLLocationCoordinate2D) async -> Void {
        if let weather = await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude) {
            self.weather = weather
        } else {
            print("Failed to fetch weather")
        }
    }
    
    func fetchForecast(url: String) async -> Void {
        if let forecast = await weatherManager.getForecast(url: url) {
            self.forecast = forecast
            currentTemp = forecast.properties.periods.first?.temperature ?? 50
        } else {
            print("Failed to fetch forecast")
        }
    }
    
    func locationInfo(_ weather: ResponseBody) -> some View {
        VStack {
            Text("\(weather.properties.relativeLocation.properties.city), \(weather.properties.relativeLocation.properties.state)")
                .font(.title2)
        }
    }
    
    private var weatherPicker: some View {
        VStack {
            Picker(selection: $selection, label: Text("View Weather")) {
                Text("Current Weather").tag(WeatherSelection.current)
                Text("Weekly Forecast").tag(WeatherSelection.future)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if let forecast = forecast {
                if selection == .current {
                    currentWeatherView(forecast)
                } else {
                    weeklyForecastView(forecast)
                }
            }
        }
        .padding()
    }
    
    private func currentWeatherView(_ forecast: ForecastBody) -> some View {
        return VStack {
            if let currentPeriod = forecast.properties.periods.first {
                Text("\(currentPeriod.shortForecast)")
                Text("\(currentPeriod.temperature)\u{00B0} \(currentPeriod.temperatureUnit)")
                    .font(.largeTitle)
                Spacer()
                Text("\(currentPeriod.detailedForecast)")
                Spacer()
                heroImage()
            } else {
                Text("There has been an issue getting today's weather. Please try again later.")
            }
            Spacer()
        }
        .padding()
    }
    
    private func weeklyForecastView(_ forecast: ForecastBody) -> some View {
        return ScrollView {
            VStack {
                ForEach(forecast.properties.periods, id: \.self) { period in
                    HStack {
                        Text(period.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(period.temperature)\u{00B0} \(period.temperatureUnit)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .onTapGesture {
                        selectedPeriod = period
                        isSheetVisible.toggle()
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $isSheetVisible) {
                DetailView(period: $selectedPeriod)
            }
        }
    }
}

struct DetailView: View {
    @Binding var period: ForecastBody.Properties.Period?

    var body: some View {
        VStack(spacing: 32) {
            if let period {
                VStack(spacing: 16) {
                    Text(period.shortForecast)
                        .font(.title2)
                    AsyncImage(url: URL(string: period.icon))
                }
                
                Text(period.detailedForecast)

                VStack {
                    Text("Humdity: \(period.relativeHumidity.value)")
                    Text("Wind: \(period.windSpeed) \(period.windDirection)")
                }
                Spacer()
            } else {
                Text("There has been an issue getting the detailed forecast. Please try again later.")
            }
            
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
