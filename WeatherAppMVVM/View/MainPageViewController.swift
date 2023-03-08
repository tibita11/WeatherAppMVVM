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
    
    private var controllers = [UIViewController]()
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
                var forecasetControllers: [UIViewController] = []
                list.forEach {
                    let threeHourForecastVC = ThreeHourForecastViewController(location: $0)
                    forecasetControllers.append(threeHourForecastVC)
                }
                self!.controllers = forecasetControllers
                self!.setViewControllers([self!.controllers[0]], direction: .forward, animated: true)
                
            })
            .disposed(by: disposeBag)
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
}
