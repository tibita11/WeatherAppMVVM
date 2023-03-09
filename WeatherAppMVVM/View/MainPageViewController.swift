//
//  MainPageViewController.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/08.
//

import UIKit
import RxSwift
import RealmSwift

class MainPageViewController: UIPageViewController {
    
    var controllers = [UIViewController]()
    /// 現在のページを保持
    var currentPage = 0
    /// Realmが更新された場合に通知されるHot Observable
    private var itemsObservable: Observable<Results<LocationList>>
    
    private let disposeBag = DisposeBag()
    
    init(observable: Observable<Results<LocationList>>) {
        itemsObservable = observable
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }
    
    /// 初期設定
    private func setUpViewController() {
        self.dataSource = self
        self.delegate = self
        // PageViewControllerとバインド
        itemsObservable
            .subscribe(onNext: { [weak self] locationList in
                guard let list = locationList.first?.list else { return }
                // controllersの設定
                var forecastControllers: [UIViewController] = []
                list.forEach {
                    let threeHourForecasetVC = ThreeHourForecastViewController(location: $0)
                    forecastControllers.append(threeHourForecasetVC)
                }
                // スクロール後のページを判定
                let previousValue = self!.controllers.count
                let currentValue = forecastControllers.count
                var page = 0
                // pageを追加した場合は、最後のページを表示するように設定する
                if previousValue != 0, previousValue < currentValue { page = currentValue - 1 }
                
                self!.controllers = forecastControllers
                self!.setUpViewControllers(page: page, direction: .forward, animated: false)
                
            })
            .disposed(by: disposeBag)
    }
    
    /// setViewControllersが必要な場合はこのメソッドを実行する
    func setUpViewControllers(page: Int,  direction: UIPageViewController.NavigationDirection, animated: Bool) {
        // ViewControllersの設定と現在ページの設定
        setViewControllers([controllers[page]], direction: direction, animated: animated)
        currentPage = page
        // 親ViewのUILabelをスライドさせる
        guard let weatherVC = parent as? WeatherViewController else { return }
        weatherVC.moveSlidingLabel(itemsCount: controllers.count , to: page)
        
    }


}


// MARK: - UIPageViewControllerDelegate

extension MainPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }
    // 左スライドで戻った時の処理
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController),
           index > 0 {
            return controllers[index - 1]
        }
        return nil
    }
    // 右スライドで進んだ時の処理
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController),
           index < controllers.count - 1 {
            return controllers[index + 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // スライド完了時のページを取得する
        guard completed, let viewController = pageViewController.viewControllers?.first, let index = controllers.firstIndex(of: viewController) else { return }
        // 現在のページを保持
        currentPage = index
        // 親ViewのUILabelをスライドさせる
        guard let weatherVC = parent as? WeatherViewController else { return }
        weatherVC.moveSlidingLabel(to: index)
        
    }
}
