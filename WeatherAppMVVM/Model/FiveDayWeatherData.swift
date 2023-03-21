//
//  ForecastData.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/18.
//

import Foundation

struct FiveDayWeatherData: Decodable {
    let list: [Forecast]
    
    struct Forecast: Decodable {
        let main: Main
        let weather: [Weather]
        let pop: Double
        let dateText: String
        
        struct Main: Decodable {
            let temp: Double
        }
        
        struct Weather: Decodable {
            let icon: String
        }
        
        enum CodingKeys: String, CodingKey {
            case main
            case weather
            case pop
            case dateText = "dt_txt"
        }
    }

}
