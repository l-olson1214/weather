//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Lindsey Olson on 1/20/24.
//

import Foundation
import CoreLocation

class WeatherManager {
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async -> ResponseBody? {
        guard let url = URL(string: "https://api.weather.gov/points/\(latitude),\(longitude)") else {
            fatalError("Missing URL")
        }
        
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Fetching data failed") }
            
            let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
            
            return decodedData
        } catch {
            print("Error fetching weather: \(error)")
        }
        
        return nil
    }
}

struct ResponseBody: Decodable {
    let id: String
    let type: String
    let geometry: Geometry
    let properties: Properties

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case geometry
        case properties
    }

    struct Geometry: Decodable {
        let type: String
        let coordinates: [Double]
    }

    struct Properties: Decodable {
        let cwa: String
        let forecastOffice: String
        let gridId: String
        let gridX: Int
        let gridY: Int
        let forecast: String
        let forecastHourly: String
        let forecastGridData: String
        let observationStations: String
        let relativeLocation: RelativeLocation
        let forecastZone: String
        let county: String
        let fireWeatherZone: String
        let timeZone: String
        let radarStation: String

        enum CodingKeys: String, CodingKey {
            case cwa
            case forecastOffice
            case gridId
            case gridX
            case gridY
            case forecast
            case forecastHourly
            case forecastGridData
            case observationStations
            case relativeLocation
            case forecastZone
            case county
            case fireWeatherZone
            case timeZone
            case radarStation
        }
    }

    struct RelativeLocation: Decodable {
        let type: String
        let geometry: Geometry
        let properties: LocationProperties

        struct Geometry: Decodable {
            let type: String
            let coordinates: [Double]
        }

        struct LocationProperties: Decodable {
            let city: String
            let state: String
            let distance: Distance
            let bearing: Bearing
        }
    }

    struct Distance: Decodable {
        let unitCode: String
        let value: Double
    }

    struct Bearing: Decodable {
        let unitCode: String
        let value: Double
    }
}
