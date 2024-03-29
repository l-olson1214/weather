//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Lindsey Olson on 1/20/24.
//

import Foundation
import CoreLocation

enum Chilliness: Int {
    case reallyCold
    case cold
    case chilly
    case mild
    case warm
    case hot
    
    init?(intValue: Int) {
        switch intValue {
        case ..<20:
            self = .reallyCold
        case 20..<30:
            self = .cold
        case 30..<40:
            self = .chilly
        case 40..<60:
            self = .mild
        case 60..<80:
            self = .warm
        case 80...:
            self = .hot
        default:
            return nil
        }
    }
}

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
    
    func getForecast(url: String) async -> ForecastBody? {
        guard let url = URL(string: url) else {
            fatalError("Missing URL")
        }
        
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Fetching data failed") }
            
            let decodedData = try JSONDecoder().decode(ForecastBody.self, from: data)
            
            return decodedData
        } catch {
            print("Error fetching weather: \(error)")
        }
        
        return nil
    }
}

// MARK: Response Body
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

// MARK: Forecast Body
struct ForecastBody: Decodable {
    let type: String
    let geometry: Geometry
    let properties: Properties

    struct Geometry: Decodable {
        let type: String
        let coordinates: [[[Double]]]
    }

    struct Properties: Decodable {
        let updated: String
        let units: String
        let forecastGenerator: String
        let generatedAt: String
        let updateTime: String
        let validTimes: String
        let elevation: Elevation
        let periods: [Period]

        struct Elevation: Decodable {
            let unitCode: String
            let value: Double
        }

        struct Period: Decodable, Identifiable, Hashable {
            static func == (lhs: ForecastBody.Properties.Period, rhs: ForecastBody.Properties.Period) -> Bool {
                return lhs.id == rhs.id
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
                hasher.combine(name)
            }
            
            let id: Int
            let name: String
            let startTime: String
            let endTime: String
            let isDaytime: Bool
            let temperature: Int
            let temperatureUnit: String
            let temperatureTrend: String?
            let probabilityOfPrecipitation: ProbabilityOfPrecipitation?
            let dewpoint: Dewpoint
            let relativeHumidity: RelativeHumidity
            let windSpeed: String
            let windDirection: String
            let icon: String
            let shortForecast: String
            let detailedForecast: String
            
            enum CodingKeys: String, CodingKey {
                case id = "number"
                case name
                case startTime
                case endTime
                case isDaytime
                case temperature
                case temperatureUnit
                case temperatureTrend
                case probabilityOfPrecipitation
                case dewpoint
                case relativeHumidity
                case windSpeed
                case windDirection
                case icon
                case shortForecast
                case detailedForecast
            }

            struct ProbabilityOfPrecipitation: Decodable {
                let unitCode: String
                let value: Int?
            }

            struct Dewpoint: Decodable {
                let unitCode: String
                let value: Double
            }

            struct RelativeHumidity: Decodable {
                let unitCode: String
                let value: Int
            }
        }
    }
}
