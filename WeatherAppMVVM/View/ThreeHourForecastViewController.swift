//
//  ThreeHourForecastViewController.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/03.
//

import UIKit

class ThreeHourForecastViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    /// 設定されている地点の情報を格納
    private var location: Location
    
    init(location: Location) {
        self.location = location
        super.init(nibName: "ThreeHourForecastViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    /// 初期設定
    private func setUp() {
        titleLabel.text = location.title
    }

}
