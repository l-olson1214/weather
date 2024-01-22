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
    @State var zipCode = ""
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 20) {
                Text("Welcome to the Weather App")
                    .bold()
                    .font(.title)

                Text("Please share your current location to get the weather in your area")
            }
            .multilineTextAlignment(.center)
            .padding()
            
            LocationButton(.shareCurrentLocation) {
                    locationManager.requestLocation()
            }
            .cornerRadius(30)
            .symbolVariant(.fill)
            .foregroundColor(.white)
            
            Text("Or")
        
            TextField("Zip Code", text: $zipCode)
                .frame(width: UIScreen.main.bounds.width / 1.50)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    locationManager.getCoordinate(from: zipCode)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    WelcomeView()
}
