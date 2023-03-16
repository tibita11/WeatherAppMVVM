//
//  OpenWeatherGateway.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/11.
//

import Foundation
import RxSwift

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
}
