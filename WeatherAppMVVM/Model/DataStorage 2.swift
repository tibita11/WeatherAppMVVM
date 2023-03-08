//
//  DataStorage.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import Foundation

import RealmSwift
import RxSwift

class DataStorage {
    
    /// Realmにデータを追加する
    func addData(object: Location) {
        let realm = try! Realm()
        // listの取得
        let result = realm.objects(LocationList.self).first
        try! realm.write {
            if let result = result {
                // 既存の場合に追加
                guard !checkingForDeplicate(object: object, list: result.list) else { return }
                result.list.append(object)
            } else {
                // listが存在しない場合は新規
                let locationList = LocationList()
                locationList.list.append(object)
                realm.add(locationList)
            }
        }
    }
    
    /// Realmからデータを削除する
    func deleteData(row: Int) {
        let realm = try! Realm()
        // listの取得
        let result = realm.objects(LocationList.self).first
        try! realm.write {
            guard let result = result else {
                return
            }
            // 指定番目を削除
            result.list.remove(at: row)
        }
        
    }
    
    /// Realmのデータを並び替える
    func moveData(from: Int, to: Int) {
        let realm = try! Realm()
        // listの取得
        let result = realm.objects(LocationList.self).first
        try! realm.write {
            guard let result = result else {
                return
            }
            // 指定番目を削除
            let object = result.list[from]
            result.list.remove(at: from)
            result.list.insert(object, at: to)
        }
    }
    
    /// 重複有無を確認する
    private func checkingForDeplicate(object: Location, list: List<Location>) -> Bool {
        var isDeplicate = false
        let subTitle = "subTitle"
        let title = "title"
        var checkingObject: (key: String, checkingText: String)
        // subTitleがある場合はsubTitleでチェック
        checkingObject = object.subTitle != "" ? (key: subTitle, checkingText: object.subTitle) : (key: title, checkingText: object.title)
        
        if checkingObject.key == subTitle {
            if list.first(where: {$0.subTitle == checkingObject.checkingText}) != nil {
                // 重複がある場合
                isDeplicate = true
            }
        } else {
            if list.first(where: {$0.title == checkingObject.checkingText}) != nil {
                // 重複がある場合
                isDeplicate = true
            }
        }
        return isDeplicate
    }
    
}
