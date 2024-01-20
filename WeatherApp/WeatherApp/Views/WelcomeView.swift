//
//  WelcomeView.swift
//  WeatherApp
//
//  Created by Lindsey Olson on 1/20/24.
//

import CoreLocation
import CoreLocationUI
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State var zipCode = "00000"
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                Text("Welcome to the Weather App")
                    .bold()
                    .font(.title)

                Text("Please share your current location to get the weather in your area")
                    .padding()
            }
            .multilineTextAlignment(.center)
            .padding()

            LocationButton(.shareCurrentLocation) {
                    locationManager.requestLocation()
            }
            .cornerRadius(30)
            .symbolVariant(.fill)
            .foregroundColor(.white)
            
            HStack {
                Text("Or, enter zipcode: ")
                TextField("Zip", text: $zipCode)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WelcomeView()
}
