//
//  WeatherViewController.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/08.
//

import UIKit
import RxSwift
import RealmSwift
import RxRealm

class WeatherViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    /// 初期設定
    private func setUp() {
        // NavigationBar設定
        let registrationButton = UIBarButtonItem(title: "地点登録", style: .plain, target: self, action: #selector(navigateToRegistrationScreen))
        navigationItem.rightBarButtonItems = [registrationButton]
        // Realm通知
        let realm = try! Realm()
        let locationList = realm.objects(Location.self)

        Observable.collection(from: locationList)
            .subscribe(onNext: { locations in
                print("これはmain画面です:\(locationList)")
            })
            .disposed(by: disposeBag)
    }
    
    /// 登録画面への遷移
    @objc private func navigateToRegistrationScreen() {
        let registrationVC = RegistrationViewController(nibName: "RegistrationViewController", bundle: nil)
        navigationController?.pushViewController(registrationVC, animated: true)
    }


}
