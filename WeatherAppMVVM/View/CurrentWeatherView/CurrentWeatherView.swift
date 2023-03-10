//
//  CurrentWeatherView.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/10.
//

import UIKit

class CurrentWeatherView: UIView {
    
    @IBOutlet weak var currentDate: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var maxTemperature: UILabel!
    
    @IBOutlet weak var minTemprature: UILabel!
    
    @IBOutlet weak var mainTitle: UILabel!
    
    @IBOutlet weak var weatherDescription: UILabel!
    
    @IBOutlet weak var clouds: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("CurrentWeatherView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
}
