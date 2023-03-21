//
//  ForecastCollectionViewCell.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/18.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var tempretureLabel: UILabel!
    
    @IBOutlet weak var precipitationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
