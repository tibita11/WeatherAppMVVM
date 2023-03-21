//
//  ForecastCollectionViewItem.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/18.
//

import Foundation
import UIKit

protocol ForecastDataDisable {
    var headerDate: String { get }
    var timeLabelText: String { get }
    var tempLabelText: String { get }
    var precipitationLableText: String { get }
    
}

struct ForecastData {
    let date: Date
    let icon: UIImage
    let temperature: Double
    let precipitation: Double
    
}

extension ForecastData: ForecastDataDisable {
    var headerDate: String {
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "d日"
        return dateFormatter.string(from: date)
    }
    
    var timeLabelText: String {
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "H時"
        return dateFormatter.string(from: date)
    }
    
    var tempLabelText: String {
        "\(Int(temperature))℃"
    }
    
    var precipitationLableText: String {
        "\(Int(precipitation * 100))%"
    }
}
