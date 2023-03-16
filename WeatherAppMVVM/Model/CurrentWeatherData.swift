//
//  CurrentWeatherData.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/10.
//

import Foundation

struct CurrentWeatherData: Decodable {
    let weather: [Weather]
    let main: Main
    let clouds: Clouds
    
    
    struct Weather: Decodable {
        let icon: String
        let main: String
        let description: String
    }
    
    struct Main: Decodable {
        let maxTemperature: Double
        let minTemperature: Double
        
        enum CodingKeys: String, CodingKey {
            case maxTemperature = "temp_max"
            case minTemperature = "temp_min"
        }
    }
    
    struct Clouds: Decodable {
        let all: Int
    }
}
