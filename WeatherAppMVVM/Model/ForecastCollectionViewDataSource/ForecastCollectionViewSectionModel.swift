//
//  ForecastCollectionViewSectionModel.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/18.
//

import Foundation
import RxDataSources

struct ForecastCollectionViewSectionModel {
    var header: String
    var items: [ForecastData]
}

extension ForecastCollectionViewSectionModel: SectionModelType {
    init(original: ForecastCollectionViewSectionModel, items: [ForecastData]) {
        self = original
        self.items = items
    }
}
