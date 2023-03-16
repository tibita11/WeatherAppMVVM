//
//  ThreeHourForecastViewController.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/03.
//

import UIKit
import RxSwift
import RxCocoa

class ThreeHourForecastViewController: UIViewController {

    /// 設定されている地点の情報を格納
    private var location: Location
    
    @IBOutlet weak var currentWeatherView: CurrentWeatherView!
    
    private var viewModel: ThreeHourForecastViewModel!
    
    private let disposeBag = DisposeBag()
    // 今日の日付を取得する
    var currentDate: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日(E)"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    
    // MARK: - View Life Cycle
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.connectingAPI(latitude: String(location.latitude), longitude: String(location.longitude))
    }
    
    
    // MARK: - Action
    
    /// 初期設定
    private func setUp() {
        viewModel = ThreeHourForecastViewModel()
        // currentWeatherViewとバインド
        viewModel.output?.currentWeatherDataObserver
            .subscribe(onNext: { [weak self] currentWeatherdata in
                guard let self = self else { return }
                // データ表示
                self.currentWeatherView.currentDate.text = "今日: \(self.currentDate)"
                self.currentWeatherView.mainTitle.text = currentWeatherdata.weather[0].main
                self.currentWeatherView.maxTemperature.text = String("\(Int(currentWeatherdata.main.maxTemperature))℃")
                self.currentWeatherView.minTemprature.text = String("\(Int(currentWeatherdata.main.minTemperature))℃")
                self.currentWeatherView.weatherDescription.text = currentWeatherdata.weather[0].description
                self.currentWeatherView.clouds.text = String(currentWeatherdata.clouds.all)
            })
            .disposed(by: disposeBag)
        // iconとバインド
        viewModel.output?.iconObserver
            .subscribe(onNext: { [weak self] image in
                guard let self = self, let image = image else {
                    return
                }
                self.currentWeatherView.icon.image = image
            })
            .disposed(by: disposeBag)
    }

}
