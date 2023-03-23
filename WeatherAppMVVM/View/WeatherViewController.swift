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
    private var locations: [Location]?
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
    
    var chiledVC: MainPageViewController!
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPageView()
        setUp()
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
        // viewModelの設定
        let viewModel = WeatherViewModel()
        viewModel.gettingDefaultLocation()
        viewModel.setUp()
        // pageViewControllerとバインド
        viewModel.output.pagesObserver
            .subscribe(onNext: { [weak self] pages in
                guard let self = self else { return }
                // collectionViewとバインド
                self.locations = pages
                self.collectionView.reloadData()
                
                var threeHourForecastViewControllers:[ThreeHourForecastViewController] = []
                pages.forEach {
                    let threeHourForecastVC = ThreeHourForecastViewController(location: $0)
                    threeHourForecastViewControllers.append(threeHourForecastVC)
                }
                // 前回ページ数
                let previousValue = self.chiledVC.controllers.count
                // 今回ページ数
                let currentValue = threeHourForecastViewControllers.count
                var page = 0
                // pageを追加した場合は、最後のページを画面に表示する
                if previousValue != 0, previousValue < currentValue { page = currentValue - 1 }
                self.chiledVC.setUpPageViewControllers(viewControllers: threeHourForecastViewControllers, page: page, direction: .forward, animated: false)
                self.moveSlidingLabel(itemsCount: threeHourForecastViewControllers.count, to: page)
                
            })
            .disposed(by: disposeBag)
        
        // 位置情報で権限エラーが出た場合のアラート表示
        viewModel.output.locationErrorObserver
            .subscribe(onNext: { [weak self] error in
                self!.showPermissionAlert(error: error)
            })
            .disposed(by: disposeBag)
        
    }
    
    /// PageViewController初期設定
    private func setUpPageView() {
        // pageViewControllerの設定
        chiledVC = MainPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        addChild(chiledVC)
        chiledVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(chiledVC.view)
        
        // オートレイアウト設定
        chiledVC.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        chiledVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        chiledVC.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        chiledVC.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        
        chiledVC.didMove(toParent: self)
        
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
    
    /// PageViewControllerのviewControllersをセットする
    func setViewControllers(page: Int) {
        chiledVC.setUpPageViewControllers(viewControllers: nil, page: page, direction: .forward, animated: false)
        moveSlidingLabel(to: page)
    }
    
    /// 位置情報の権限エラーに関するアラート生成
    private func showPermissionAlert(error: LocationError) {
        let alert = UIAlertController(title: "位置情報", message: error.localizedDescription, preferredStyle: .alert)
        
        if error == .authorityError {
            // 権限エラーの場合は設定画面を開くボタンを追加
            let goToSetting = UIAlertAction(title: "設定に移動", style: .default) { _ in
                // 設定画面を開く処理
                guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingUrl) {
                    UIApplication.shared.open(settingUrl)
                }
            }
            alert.addAction(goToSetting)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
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
        
        moveSlidingLabel(to: page)
        mainPageVC.setUpPageViewControllers(viewControllers: nil, page: page, direction: direction, animated: true)
    }
    
    
}
