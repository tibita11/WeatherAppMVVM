//
//  WeatherViewController.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/08.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

class WeatherViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    /// CollectionViewに表示するデータを格納
    private var locations: List<Location>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    /// 初期設定
    private func setUp() {
        // NavigationBar設定
        let registrationButton = UIBarButtonItem(title: "地点登録", style: .plain, target: self, action: #selector(navigateToRegistrationScreen))
        navigationItem.rightBarButtonItems = [registrationButton]
        // CollectionView設定
        collectionView.register(UINib(nibName: "LocationTabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "locationCell")
        collectionView.rx.setDataSource(self).disposed(by: disposeBag)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        // Realm通知
        let realm = try! Realm()
        let locationList = realm.objects(LocationList.self)
        // collectionViewとバインド
        Observable.collection(from: locationList)
            .subscribe(onNext: { [weak self] locationList in
                // 取得したlistを格納
                self!.locations = locationList.first?.list
                self!.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    /// 登録画面への遷移
    @objc private func navigateToRegistrationScreen() {
        let registrationVC = RegistrationViewController(nibName: "RegistrationViewController", bundle: nil)
        navigationController?.pushViewController(registrationVC, animated: true)
    }


}


// MARK: - UICollectionViewDataSource

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as! LocationTabCollectionViewCell
        cell.locationLabel.text = locations?[indexPath.row].title ?? ""
        return cell
    }

}


// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // cellサイズ
        let width = collectionView.bounds.width / CGFloat(collectionView.numberOfItems(inSection: 0))
        return CGSize(width: width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // cell間隔0
        return 0
    }
    
}
