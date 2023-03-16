//
//  OpenWeatherAPIClient.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/10.
//

import Foundation
import Alamofire


protocol APIClient {
    var url: String { get }
    func getRequest(_ parameters: [String : String]) -> DataRequest
}


class CurrentWeatherAPIClient: APIClient {
    var url = "https://api.openweathermap.org/data/2.5/weather"
    
    func getRequest(_ parameters: [String : String]) -> DataRequest {
        return AF.request(url, parameters: parameters)
    }
    
}


class ThreeHourForecastAPIClient: APIClient {
    var url = "https://api.openweathermap.org/data/2.5/forecast"
    
    func getRequest(_ parameters: [String : String]) -> DataRequest {
        return AF.request(url, parameters: parameters)
    }

}

