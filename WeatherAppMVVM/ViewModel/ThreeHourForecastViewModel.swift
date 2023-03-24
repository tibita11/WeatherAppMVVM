//
//  ThreeHourForecastViewModel.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/10.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher


protocol ThreeHourForecastViewModelOutput {
    var currentWeatherDataObserver: Observable<CurrentWeatherData> { get }
    var iconObserver: Observable<UIImage?> { get }
    var forecastSectionModelObserver: Observable<[ForecastCollectionViewSectionModel]> { get }
}


protocol ThreeHourForecastViewModelType {
    var output: ThreeHourForecastViewModelOutput? { get }
}


class ThreeHourForecastViewModel: ThreeHourForecastViewModelType {
    var output: ThreeHourForecastViewModelOutput?
    
    private let disposeBag = DisposeBag()
    
    private let currentWeatherData = PublishRelay<CurrentWeatherData>()
    
    private let icon = PublishRelay<UIImage?>()
    /// collectionViewとバインドするデータ
    private let forecastSectionModel = PublishRelay<[ForecastCollectionViewSectionModel]>()
    
    init() {
        self.output = self
    }
    
    /// APIと接続をする
    func connectingAPI(latitude: String, longitude: String) {
        let gateway = OpenWeatherGateway()
        let parameters = ["lat" : latitude, "lon" : longitude, "units" : "metric", "appid" : openWeatherAPIKey]
        // 現在の天気を取得する
        gateway.gettingCurrentWeather(paramters: parameters)
            .subscribe { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let currentWeatherData):
                    self.currentWeatherData.accept(currentWeatherData)
                    // icon設定
                    guard let url = self.gettingIconURL(iconName: currentWeatherData.weather[0].icon) else { return }
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        switch result {
                        case .success(let value):
                            self.icon.accept(value.image)
                        case .failure(let error):
                            self.icon.accept(nil)
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        // 5日間の天気を取得する
        gateway.gettingFiveDayWeather(parameters: parameters)
            .subscribe { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let fiveDayWeatherData):
                    // 非同期処理をまとめる
                    let dispatchGroup = DispatchGroup()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(identifier: "UTC")
                    // 変換後のデータを格納する
                    var forecastDataArray: [ForecastData] = []
                    
                    for data in fiveDayWeatherData.list {
                        
                            if let url = self.gettingIconURL(iconName: data.weather[0].icon) {
                                dispatchGroup.enter()
                                KingfisherManager.shared.retrieveImage(with: url) { result in
                                    switch result {
                                    case .success(let value):
                                        let date = dateFormatter.date(from: data.dateText)
                                        let newObject = ForecastData(date: date!, icon: value.image, temperature: data.main.temp, precipitation: data.pop)
                                        forecastDataArray.append(newObject)
                                    case .failure(let error):
                                        let date = dateFormatter.date(from: data.dateText)
                                        let newObject = ForecastData(date: date!, icon: UIImage(), temperature: data.main.temp, precipitation: data.pop)
                                        forecastDataArray.append(newObject)
                                        print("画像取得失敗: \(error.localizedDescription)")
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    
                    // 全ての非同期処理完了後に実行
                    dispatchGroup.notify(queue: .main) {
                        self.forecastSectionModel.accept(self.setUpForecastSectionModel(forecastDataArray: forecastDataArray))
                    }
                    
                case .failure(let error):
                    print("予報データ取得失敗: \(error.localizedDescription)")
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    /// iconを取得するためのURLを取得する
    private func gettingIconURL(iconName: String) -> URL? {
        let urlString = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
        if let url = URL(string: urlString) {
            return url
        } else {
            return nil
        }
    }
    
    /// 予報データを日付毎にセクションに分ける
    private func setUpForecastSectionModel(forecastDataArray: [ForecastData]) -> [ForecastCollectionViewSectionModel] {
        var forecastSectionModel : [ForecastCollectionViewSectionModel] = []
        var currentSection: [ForecastData] = []
        
        let sortedData = forecastDataArray.sorted(by: { $0.date < $1.date })
        
        for object in sortedData {
            if currentSection.isEmpty || object.headerDate == currentSection[0].headerDate {
                currentSection.append(object)
            } else {
                forecastSectionModel.append(ForecastCollectionViewSectionModel(header: currentSection[0].headerDate, items: currentSection))
                currentSection = [object]
            }
        }
        // 最後のセクションを追加する
        if !currentSection.isEmpty {
            forecastSectionModel.append(ForecastCollectionViewSectionModel(header: currentSection[0].headerDate, items: currentSection))
        }
        
        return forecastSectionModel
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
    
    var forecastSectionModelObserver: Observable<[ForecastCollectionViewSectionModel]> {
        return forecastSectionModel.asObservable()
    }
    
}
