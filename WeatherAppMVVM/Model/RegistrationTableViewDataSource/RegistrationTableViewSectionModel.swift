//
//  SectionModel.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import Foundation
import RxDataSources

typealias RegistrationTableViewSectionModel = SectionModel<RegistrationTableViewSection, CellType>

enum RegistrationTableViewSection {
    case searchKeyword
    case searchCurrentLocation
    case registerdLocation
    
    var title: String {
        switch self {
        case .searchKeyword:
            return "キーワードから探す"
        case .searchCurrentLocation:
            return "現在地から探す"
        case .registerdLocation:
            return "現在登録されている地点"
        }
    }
    
    var number: Int {
        switch self {
        case .searchKeyword:
            return 0
        case .searchCurrentLocation:
            return 1
        case .registerdLocation:
            return 2
        }
    }
}

enum CellType {
    /// 登録地点を格納するCellType
    case locationType(LocationData)
    /// 登録地点以外を格納するCellType
    case defaultsType(DefaultsData)
}
