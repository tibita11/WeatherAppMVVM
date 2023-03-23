//
//  ThreeHourForecastViewController.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/03.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ThreeHourForecastViewController: UIViewController {

    /// 設定されている地点の情報を格納
    private var location: Location
    
    @IBOutlet weak var currentWeatherView: CurrentWeatherView!
    
    private var viewModel: ThreeHourForecastViewModel!
    
    private let disposeBag = DisposeBag()
    /// 今日の日付を取得する
    var currentDate: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日(E)"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    /// FiveDayWeatherViewの土台View
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var fiveDayWeatherView: FiveDayWeatherView!
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<ForecastCollectionViewSectionModel>(configureCell: {
        (dataSource, collectionView, indexPath, item) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCollectionViewCell", for: indexPath) as! ForecastCollectionViewCell
        cell.timeLabel.text = item.timeLabelText
        cell.iconImage.image = item.icon
        cell.tempretureLabel.text = item.tempLabelText
        cell.precipitationLabel.text = item.precipitationLableText
        return cell
    }, configureSupplementaryView: {
        (dataSource, collectionView, kind, index) in
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ForecastCollectionViewHeader", for: index) as! ForecastCollectionViewHeader
        header.headerLabel.text = dataSource[index.section].header
        return header
    })
    
    
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
        setUpFiveDayWeatherView()
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
                guard let self = self, let iconImage = image else {
                    self?.currentWeatherView.icon.image = UIImage()
                    return
                }
                self.currentWeatherView.icon.image = iconImage
            })
            .disposed(by: disposeBag)
        // 角丸・影
        baseView.layer.cornerRadius = 20
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 3.0
        baseView.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
    }
    
    /// 初期設定
    private func setUpFiveDayWeatherView() {
        fiveDayWeatherView.collectionView.register(UINib(nibName: "ForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCollectionViewCell")
        fiveDayWeatherView.collectionView.register(UINib(nibName: "ForecastCollectionViewHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ForecastCollectionViewHeader")
        fiveDayWeatherView.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        // collectionViewとバインド
        viewModel.output?.forecastSectionModelObserver
            .bind(to: fiveDayWeatherView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }

}

extension ThreeHourForecastViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // セルサイズ
        return CGSize(width: 50, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // ヘッダーサイズ
        return CGSize(width: 40, height: collectionView.bounds.height)
    }
    
}
