//
//  DataFormatter.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import Foundation

class DataFormatter {
    
    private var keywordSearchSection: RegistrationTableViewSectionModel {
        // 初期データ
        let placeAndFacility = DefaultsData(type: .placeAndFacility)
        let items: [CellType] = [CellType.defaultsType(placeAndFacility)]
        return RegistrationTableViewSectionModel(model: .searchKeyword, items: items)
    }
    
    private var currentLocationSection: RegistrationTableViewSectionModel {
        // 初期データ
        let currentLocation = DefaultsData(type: .searchCurrentLocation)
        let items: [CellType] = [CellType.defaultsType(currentLocation)]
        return RegistrationTableViewSectionModel(model: .searchCurrentLocation, items: items)
    }
    
    /// 初期データと結合し、Section配列で返す
    func sectionArray(from items: [CellType]) -> [RegistrationTableViewSectionModel] {
        let registerdLocationSection = RegistrationTableViewSectionModel(model: .registerdLocation, items: items)
        let sectionArray = [keywordSearchSection, currentLocationSection, registerdLocationSection]
        return sectionArray
    }
    
}

