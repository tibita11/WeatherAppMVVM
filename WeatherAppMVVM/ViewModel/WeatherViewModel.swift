//
//  WeatherViewModel.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/23.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import CoreLocation


protocol WeatherViewModelOutput {
    var pagesObserver: Observable<[Location]> { get }
    var locationErrorObserver: Observable<LocationError> { get }
}

protocol WeatherViewModelType {
    var output: WeatherViewModelOutput! { get }
}


class WeatherViewModel: NSObject, WeatherViewModelType {
    var output: WeatherViewModelOutput!
    
    private let disposeBag = DisposeBag()
    /// Viewに加工後の配列を送る
    private let pages = PublishRelay<[Location]>()
    /// Realmから取得したデータ
    private let locationList = PublishRelay<[Location]>()
    /// 現在地から取得したデータ
    private let defaultLocation = PublishRelay<Location>()
    /// 現在地を取得するため
    private let locationManager = CLLocationManager()
    /// 現在地が取得できない場合のデフォルトLocation
    private var ChiyodaLocation: Location {
        let location = Location()
        location.title = "東京都 千代田区"
        location.latitude = 35.6811
        location.longitude = 139.767
        return location
    }
    /// 現在地の設定を促すエラーを送る
    private let locationError = PublishRelay<LocationError>()
    
    override init() {
        super.init()
        
        output = self
    }
    
    
    func setUp() {
        // Realmに登録された内容と、初期データを合わせる
        let combined = Observable
            .combineLatest(locationList, defaultLocation) { registeredLocations, defaultLocations in
                var combinedLocations = registeredLocations
                combinedLocations.insert(defaultLocations, at: 0)
                return combinedLocations
            }
        
        combined
            .subscribe(onNext: { [weak self] combinedLocations in
                self!.pages.accept(combinedLocations)
            })
            .disposed(by: disposeBag)
        
        // 起動時と、Realm更新時に発火する
        let realm = try! Realm()
        let locationList = realm.objects(LocationList.self)
        let itemsObserver = Observable.collection(from: locationList)
        
        itemsObserver
            .subscribe(onNext: { [weak self] locationList in
                guard let self = self else { return }
                              
                var locations: [Location] = []
                guard let list = locationList.first?.list else {
                    // 登録なしの場合は空配列を送る
                    self.locationList.accept(locations)
                    return
                }
                
                list.forEach {
                    // 登録ありの場合
                    locations.append($0)
                }

                self.locationList.accept(locations)
            })
            .disposed(by: disposeBag)
        
    }
    
    /// 現在地または千代田区のデータを取得する
    func gettingDefaultLocation() {
        locationManager.delegate = self
        // 精度の選択
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
}


// MARK: - WeatherViewModelOutput

extension WeatherViewModel: WeatherViewModelOutput {
    var pagesObserver: Observable<[Location]> {
        return pages.asObservable()
    }
    
    var locationErrorObserver: Observable<LocationError> {
        return locationError.asObservable()
    }
    
}


// MARK: - CLLocationManagerDelegate

extension WeatherViewModel: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            // 許可されていない場合、許可選択画面を表示する
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // 拒否されている場合、アラート表示、デフォルトLocation設定
            defaultLocation.accept(ChiyodaLocation)
            locationError.accept(LocationError.authorityError)
        case .authorizedAlways, .authorizedWhenInUse:
            // 許可されている場合、検索を開始する
            locationManager.startUpdatingLocation()
            
        @unknown default:
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 現在位置の取得に成功した場合の処理
        locationManager.stopUpdatingLocation()
        
        guard let location = locations.last else {
            // 取得できなかった場合は、デフォルトLocationを設定
            defaultLocation.accept(ChiyodaLocation)
            return
        }
        // 経度緯度の取得
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        // Lovationデータを作成
        let newLocation = Location()
        newLocation.latitude = Double(latitude)
        newLocation.longitude = Double(longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            // 逆ジオコーディングにより住所取得
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // 取得できた場合のみDBに保存する
            guard let placemark = placemarks?.first, let administrativeArea = placemark.administrativeArea, let locality = placemark.locality else {
                return
            }
            newLocation.title = "現在地: \(administrativeArea) \(locality)"
            self!.defaultLocation.accept(newLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 現在位置の取得に失敗した場合の処理
        print("現在地の取得に失敗しました。\(error)")
        defaultLocation.accept(ChiyodaLocation)
    }
    
    
}
