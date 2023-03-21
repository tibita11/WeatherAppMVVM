//
//  FiveDayWeatherView.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/17.
//

import UIKit

class FiveDayWeatherView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    func loadNib() {
        let view = Bundle.main.loadNibNamed("FiveDayWeatherView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }

}
