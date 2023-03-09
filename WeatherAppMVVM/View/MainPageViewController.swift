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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
    }
    
    /// PageViewControlerの初期設定
    /// - Parameter viewControllers: page数に変更がなければnil
    /// - Parameter page: setするpage番号
    /// - Parameter direction: 方向
    /// - Parameter animated: スクロール時のアニメーション可否
    func setUpPageViewControllers(viewControllers: [UIViewController]?, page: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        // pageViewControllerを更新する場合
        if let viewControllers = viewControllers { controllers = viewControllers }
        // 指定番目を表示
        setViewControllers([controllers[page]], direction: direction, animated: animated)
        currentPage = page
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
