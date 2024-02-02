//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Lindsey Olson on 1/20/24.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
