//
//  Geocoder.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import Foundation
import CoreLocation


class Geocoder {
    /// 住所から経度緯度を返す
    /// - Parameter address: 住所
    func coordinate(address: String, completion: @escaping ((CLLocationCoordinate2D?) -> ())) {
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if let firstPlacemark = placemarks?.first, let location = firstPlacemark.location {
                let coordinate = location.coordinate
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }
}
