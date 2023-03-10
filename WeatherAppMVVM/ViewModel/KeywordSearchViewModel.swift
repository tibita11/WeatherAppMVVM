//
//  KeywordSearchViewModel.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa


struct KeywordSearchViewModelInput {
    let keywordSearchBar: Observable<String?>
    let itemSelected: ControlEvent<IndexPath>
}

protocol KeywordSearchViewModelOutput: AnyObject {
    var resultsObserver: Observable<[MKLocalSearchCompletion]> { get }
    var selectedDataObserver: Observable<MKLocalSearchCompletion?> { get }
}


protocol KeywordSearchViewModelType {
    var output: KeywordSearchViewModelOutput? { get }
    func setup(input: KeywordSearchViewModelInput)
}


class KeywordSearchViewModel: NSObject, KeywordSearchViewModelType {
    
    weak var output: KeywordSearchViewModelOutput?
    
    private let disposeBag = DisposeBag()
    /// サジェスト機能を使用する
    private var searchCompleter = MKLocalSearchCompleter()
    /// サジェスト結果を格納する
    private let results = BehaviorRelay<[MKLocalSearchCompletion]>(value: [])
    /// 選択したセルの値を格納する
    private let selectdData = BehaviorRelay<MKLocalSearchCompletion?>(value: nil)
    
    /// 初期設定
    func setup(input: KeywordSearchViewModelInput) {
        // delegate設定
        output = self
        searchCompleter.delegate = self
        
        // 検索バーの文字列からデータを取得する
        input.keywordSearchBar
            .subscribe(onNext: { [weak self] keyword in
                guard let keyword = keyword else { return }
                self!.searchCompleter.queryFragment = keyword
            })
            .disposed(by: disposeBag)
        
        // タップされた行のDataを取得する
        input.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let currentData = self!.results.value
                let selectedData = currentData[indexPath.row]
                self!.selectdData.accept(selectedData)
            })
            .disposed(by: disposeBag)
        
    }
    
    
    /// 経度緯度を取得して、Realmに保存する
    func saveData(completion: @escaping ((Error?) -> ())) {
        // 経度緯度を取得
        guard let data = selectdData.value else { return }
        let address = data.subtitle != "" ? data.subtitle : data.title
        
        Geocoder().coordinate(address: address) { coordinate in
            guard let coordinate = coordinate else {
                return completion(SearchError.fetchFailed)
            }
            // Realmに保存
            let location = Location()
            location.title = data.title
            location.subTitle = data.subtitle
            location.latitude = Double(coordinate.latitude)
            location.longitude = Double(coordinate.longitude)
            // 重複チェック
            guard let deplicateIndex = DataStorage().checkingForDeplicate(object: location) else {
                // 重複がない場合に、保存する
                DataStorage().addData(object: location)
                return completion(nil)
            }
            // 重複がある場合はindexを返す
            return completion(SearchError.deplicateError(index: deplicateIndex))
        }
    }
    
    
    
}


// MARK: - MKLocalSearchCompleterDelegate
extension KeywordSearchViewModel: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // 検索が成功した際の処理
        results.accept(searchCompleter.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // 検索が失敗した際の処理
        results.accept([])
    }
    
}


// MARK: - KeywordSearchViewModelOutput
extension KeywordSearchViewModel: KeywordSearchViewModelOutput {
    
    var resultsObserver: Observable<[MKLocalSearchCompletion]> {
        return results.asObservable()
    }
    
    var selectedDataObserver: Observable<MKLocalSearchCompletion?> {
        return selectdData.asObservable()
    }
    
    
    
}

// MARK: - Error
enum SearchError: LocalizedError {
    case fetchFailed
    case deplicateError(index: Int)
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "経度緯度の取得ができませんでした。"
        case .deplicateError:
            return "重複しています。"
        }
    }
}
