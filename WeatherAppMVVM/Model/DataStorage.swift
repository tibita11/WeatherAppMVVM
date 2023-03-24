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
            let object = result.list[row]
            result.list.remove(at: row)
            realm.delete(object)
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
    /// - Parameter object: 重複の確認をするオブジェクト
    /// - Returns: 重複しているindex, 重複がない場合nil
    func checkingForDeplicate(object: Location) -> Int? {
        // listの取得
        let realm = try! Realm()
        guard let result = realm.objects(LocationList.self).first?.list else { return nil }
        // 重複チェック
        var deplicateIndex: Int? = nil
        let subTitle = "subTitle"
        let title = "title"
        var checkingObject: (key: String, checkingText: String)
        // subTitleがある場合はsubTitleでチェック
        checkingObject = object.subTitle != "" ? (key: subTitle, checkingText: object.subTitle) : (key: title, checkingText: object.title)
        
        if checkingObject.key == subTitle {
            if let index = result.firstIndex(where: {$0.subTitle == checkingObject.checkingText}) {
                // 重複がある場合
                // Defaultで表示される分を加算
                deplicateIndex = index + 1
            }
        } else {
            if let index = result.firstIndex(where: {$0.title == checkingObject.checkingText}) {
                // 重複がある場合
                // Defaultで表示される分を加算
                deplicateIndex = index + 1
            }
        }
        return deplicateIndex
    }
    
}
