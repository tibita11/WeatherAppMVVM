//
//  RegistrationViewModel.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import CoreLocation

struct RegistrationViewInput {
    let itemDeleted: ControlEvent<IndexPath>
    let itemMoved: ControlEvent<ItemMovedEvent>
}


protocol RegistrationViewModelOutput: AnyObject {
    var itemObserver: Observable<[SettingSectionModel]> { get }
    var locationErrorObserver: Observable<LocationError> { get }
    var isUpdatingObserver: Observable<Bool> { get }
}


protocol RegistrationViewModelType {
    var output: RegistrationViewModelOutput? { get }
    func setupMainView(input: RegistrationViewInput)
}

class RegistrationViewModel: NSObject, RegistrationViewModelType {
    
    weak var output: RegistrationViewModelOutput?
    
    private let disposeBag = DisposeBag()
    
    private let item = PublishRelay<[SettingSectionModel]>()
    /// 現在位置取得のため
    private let locationManager = CLLocationManager()
    /// 現在位置取得に失敗した場合の通知
    private let locationError = PublishRelay<LocationError>()
    /// 現在位置取得の開始終了を通知
    private let isUpdating = PublishRelay<Bool>()
    
    override init() {
        super.init()
        
        output = self
    }
    
    /// MainViewの初期設定
    func setupMainView(input: RegistrationViewInput) {
        // DBから削除
        input.itemDeleted
            .subscribe(onNext: { indexPath in
                DataStorage().deleteData(row: indexPath.row)
            })
            .disposed(by: disposeBag)
        
        // 並び替え
        input.itemMoved
            .subscribe(onNext: { indexPath in
                DataStorage().moveData(from: indexPath.sourceIndex.row, to: indexPath.destinationIndex.row)
            })
            .disposed(by: disposeBag)
        
        // DBが更新された場合に発火
        let realm = try! Realm()
        let locationList = realm.objects(LocationList.self)
        // 更新通知
        Observable.collection(from: locationList)
            .subscribe(onNext: { [weak self] locationList in
                print("これは登録画面です:\(locationList)")
                var items: [CellType] = []
                if let locationList = locationList.first {
                    // listに値がある場合
                    locationList.list.forEach {
                        let locationData = LocationData(title: $0.title, latitude: $0.latitude, longitude: $0.longitude)
                        let cellType = CellType.locationType(locationData)
                        items.append(cellType)
                    }
                }
                let sectionArray = DataFormatter().sectionArray(from: items)
                // UI更新
                self!.item.accept(sectionArray)
            })
            .disposed(by: disposeBag)
        
    }
    
    /// 現在位置の取得
    func gettingCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        startUpLocationManager()
    }
    
    /// LocationManagerの現在位置取得を開始する
    private func startUpLocationManager() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // 許可されていない場合
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // 拒否されている場合
            locationError.accept(LocationError.authorityError)
        case .authorizedAlways, .authorizedWhenInUse:
            // 許可されている場合
            // 更新中Viewを表示
            isUpdating.accept(true)
            locationManager.startUpdatingLocation()
            
        @unknown default:
            break
        }
    }
    
}


// MARK: - MainViewModelOutput
extension RegistrationViewModel: RegistrationViewModelOutput {
    var itemObserver: Observable<[SettingSectionModel]> {
        return item.asObservable()
    }
    
    var locationErrorObserver: Observable<LocationError> {
        return locationError.asObservable()
    }
    
    var isUpdatingObserver: Observable<Bool> {
        return isUpdating.asObservable()
    }
}


// MARK: - CLLocationManagerDelegate
extension RegistrationViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 権限が変更された際の処理
        let authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            // 権限が許可された場合に取得を開始する
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 現在位置の取得に成功した場合の処理
        locationManager.stopUpdatingLocation()
        // 2回呼ばれてしまう対処法
        locationManager.delegate = nil
        
        guard let location = locations.last else { return }
        // 経度緯度の取得
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        // DB登録用のデータ作成
        let newLocation = Location()
        newLocation.latitude = Double(latitude)
        newLocation.longitude = Double(longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            // 逆ジオコーディングにより住所取得
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first, let administrativeArea = placemark.administrativeArea, let locality = placemark.locality else {
                return
            }
            newLocation.title = "\(administrativeArea)\(locality)"
            // DBに保存
            DataStorage().addData(object: newLocation)
            // 更新中Viewを非表示
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                // 非表示を遅らせる
                self!.isUpdating.accept(false)
            }
            
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 現在位置の取得に失敗した場合の処理
        locationError.accept(LocationError.connectionError)
    }
    
}


// MARK: - LocationError
enum LocationError: LocalizedError {
    case authorityError
    case connectionError
    
    var errorDescription: String? {
        switch self {
        case .authorityError:
            return "位置情報サービスを利用できません。利用するには端末設定の「プライバシーとセキュリティ>位置情報サービス 」より許可してください"
        case .connectionError:
            return "現在位置の取得に失敗しました。"
        }
    }
}
