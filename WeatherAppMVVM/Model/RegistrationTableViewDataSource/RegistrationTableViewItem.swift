//
//  ItemData.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import Foundation

enum DefaultsDataType {
    case placeAndFacility
    case searchCurrentLocation
    
    var title: String {
        switch self {
        case .placeAndFacility:
            return "地名・施設名など"
        case .searchCurrentLocation:
            return "現在地から探す"
        }
    }
    
    var image: String {
        switch self {
        case .placeAndFacility:
            return "magnifyingglass"
        case .searchCurrentLocation:
            return "globe"
        }
    }
}

/// 経度緯度を表示するセル用
struct LocationData {
    var title: String
    var latitude: Double
    var longitude: Double
    
    init(title: String, latitude: Double, longitude: Double) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// キーワード・現在地を表示するセル用
struct DefaultsData {
    var type: DefaultsDataType
    
    init(type: DefaultsDataType) {
        self.type = type
    }
}
