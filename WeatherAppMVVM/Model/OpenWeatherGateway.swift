//
//  OpenWeatherGateway.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/11.
//

import Foundation
import RxSwift
import Alamofire

enum ConnectingAPIError: LocalizedError {
    case noData
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "情報の取得ができませんでした。"
        }
    }
}

class OpenWeatherGateway {
    
    /// 現在の天気を取得する
    func gettingCurrentWeather(paramters: [String : String]) -> Single<CurrentWeatherData> {
        
        return Single<CurrentWeatherData>.create { singleEvent in
            let request = CurrentWeatherAPIClient().getRequest(paramters)
                .validate()
                .responseDecodable(of: CurrentWeatherData.self) { response in
                    guard let result = response.value else {
                        return singleEvent(.failure(ConnectingAPIError.noData))
                    }
                    singleEvent(.success(result))
                }
            return Disposables.create{ request.cancel() }
        }
    }
    
    /// 5日間の天気を取得する
    func gettingFiveDayWeather(parameters: [String : String]) -> Single<FiveDayWeatherData>{
        
        return Single<FiveDayWeatherData>.create { singleEvent in
            let request = ThreeHourForecastAPIClient().getRequest(parameters)
                .validate()
                .responseDecodable(of: FiveDayWeatherData.self) { response in
                    guard let result = response.value else {
                        return singleEvent(.failure(ConnectingAPIError.noData))
                    }
                    singleEvent(.success(result))
                }
            return Disposables.create { request.cancel() }
        }
    }
    
    /// 天気アイコンのデータを取得する
    func gettingIconData(icon: String) -> Single<Data> {
        let url = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        return Single<Data>.create { singleEvent in
            let request = AF.request(url)
                .validate()
                .response { response in
                    guard let data = response.data else {
                        return singleEvent(.failure(ConnectingAPIError.noData))
                    }
                    singleEvent(.success(data))
                }
            return Disposables.create { request.cancel() }
        }
    }
}
