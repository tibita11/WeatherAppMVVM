//
//  ThreeHourForecastViewModel.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/10.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire


protocol ThreeHourForecastViewModelOutput {
    var currentWeatherDataObserver: Observable<CurrentWeatherData> { get }
    var iconObserver: Observable<UIImage?> { get }
}


protocol ThreeHourForecastViewModelType {
    var output: ThreeHourForecastViewModelOutput? { get }
}


class ThreeHourForecastViewModel: ThreeHourForecastViewModelType {
    var output: ThreeHourForecastViewModelOutput?
    
    private let disposeBag = DisposeBag()
    
    private let currentWeatherData = PublishRelay<CurrentWeatherData>()
    
    private let icon = PublishRelay<UIImage?>()
    
    init() {
        self.output = self
    }
    
    /// APIと接続をする
    func connectingAPI(latitude: String, longitude: String) {
        let parameters = ["lat" : latitude, "lon" : longitude, "units" : "metric", "appid" : openWeatherAPIKey]
        OpenWeatherGateway().gettingCurrentWeather(paramters: parameters)
            .subscribe { [weak self] event in
                switch event {
                case .success(let currentWeatherData):
                    self!.currentWeatherData.accept(currentWeatherData)
                    // icon取得
                    self!.gettingImage(iconName: currentWeatherData.weather[0].icon)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    /// urlからImageDataを取得する
    private func gettingImage(iconName: String) {
        let url = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
        AF.request(url)
            .validate()
            .response { [weak self] response in
                guard let self = self else { return }
                // data取得
                guard let data = response.data else {
                    return self.icon.accept(nil)
                }
                return self.icon.accept(UIImage(data: data))
            }
    }
    
    
}


// MARK: - ThreeHourForecastViewModelOutput

extension ThreeHourForecastViewModel: ThreeHourForecastViewModelOutput {
    var currentWeatherDataObserver: Observable<CurrentWeatherData> {
        return currentWeatherData.asObservable()
    }
    
    var iconObserver: Observable<UIImage?> {
        return icon.asObservable()
    }
    
    
}
