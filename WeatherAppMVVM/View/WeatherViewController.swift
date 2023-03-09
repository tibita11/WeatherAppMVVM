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
    
    @IBOutlet weak var containerView: UIView!
    
    private let disposeBag = DisposeBag()
    /// CollectionViewに表示するデータを格納
    private var locations: List<Location>?
    /// Realmが更新された場合に通知されるHot Observable
    var itemsObservable: Observable<Results<LocationList>>!
    /// CollectionView下部に設置
    private let slidingLabel = UILabel()
    /// NavigationBar下部までの高さ
    var heightToNavBar: CGFloat {
        var height: CGFloat = 0
        if let navigationController = self.navigationController {
            let navBarMaxY = navigationController.navigationBar.frame.maxY
            let statusBarHeight = navigationController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            height = navBarMaxY + statusBarHeight
        }
        return height
    }
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpPageView()
    }
    
    
    // MARK: - Action
    
    /// 初期設定
    private func setUp() {
        // CollectionView下部にUILabelを設置
        slidingLabel.frame = CGRect(x: 0, y: heightToNavBar + collectionView.bounds.height, width: 0, height: 0.5)
        slidingLabel.backgroundColor = .darkGray
        view.addSubview(slidingLabel)
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
        itemsObservable = Observable.collection(from: locationList).share(replay: 1)
        // collectionViewとバインド
        itemsObservable
            .subscribe(onNext: { [weak self] locationList in
                // 取得したlistを格納
                self!.locations = locationList.first?.list
                self!.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    /// PageViewController初期設定
    private func setUpPageView() {
        let mainPageVC = MainPageViewController(observable: itemsObservable)
        addChild(mainPageVC)
        mainPageVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(mainPageVC.view)
        // オートレイアウト設定
        mainPageVC.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        mainPageVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        mainPageVC.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        mainPageVC.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        
        mainPageVC.didMove(toParent: self)
        
    }
    
    /// 登録画面への遷移
    @objc private func navigateToRegistrationScreen() {
        let registrationVC = RegistrationViewController(nibName: "RegistrationViewController", bundle: nil)
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    /// pageまでSlifdingLabelをスライドさせる
    /// - Parameter itemsCount: 配列の総数
    /// - Parameter page: ページ番号
    func moveSlidingLabel(itemsCount: Int? = nil, to page: Int) {
        if let itemsCount = itemsCount {
            // itemsが更新されている場合は幅を更新する
            slidingLabel.frame.size.width = view.bounds.width / CGFloat(itemsCount)
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, animations: { [weak self] in
            self!.slidingLabel.frame.origin.x = self!.slidingLabel.bounds.width * CGFloat(page)
        })
        
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
        cell.tag = indexPath.row
        cell.delegate = self
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


// MARK: - LocationTabCollectionViewCellDelegate

extension WeatherViewController: LocationTabCollectionViewCellDelegate {
    func moveCurrentPage(to page: Int) {
        guard let mainPageVC = children.first as? MainPageViewController else { return }
        // 進む方向を判断する
        let currentPage = mainPageVC.currentPage
        var direction: UIPageViewController.NavigationDirection = .forward
        if currentPage > page { direction = .reverse }
        
        mainPageVC.setUpViewControllers(page: page, direction: direction, animated: true)
    }
    
    
}
