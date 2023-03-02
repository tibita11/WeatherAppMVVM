//
//  Location.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import Foundation
import RealmSwift

/// Realmに保存する用のクラス
class Location: Object {
    @Persisted var title: String
    @Persisted var subTitle: String
    @Persisted var latitude: Double
    @Persisted var longitude: Double
}

class LocationList: Object {
    let list = List<Location>()
}
