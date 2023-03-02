//
//  KeywordSearchViewController.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class KeywordSearchViewController: UIViewController {

    @IBOutlet weak var keywordSearchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: KeywordSearchViewModel!
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - View Life Cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = KeywordSearchViewModel()
        setup()
        setupTabelView()
        setupSearchBar()
        setupAlertController()
    }
    
    
    // MARK: - Action
    
    /// 初期設定
    private func setup() {
        let input = KeywordSearchViewModelInput(keywordSearchBar: keywordSearchBar.rx.text.asObservable(), itemSelected: tableView.rx.itemSelected)
        viewModel.setup(input: input)
        
    }
    
    /// TableViewの初期設定
    private func setupTabelView() {
        tableView.keyboardDismissMode = .onDrag
        // Cell設定
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // TableViewを更新する処理
        viewModel.output?.resultsObserver
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { row, element, cell in
                var config = cell.defaultContentConfiguration()
                config.text = element.title
                config.secondaryText = element.subtitle
                cell.contentConfiguration = config
            }
            .disposed(by: disposeBag)
        
    }
    
    /// SearchBarの初期設定
    private func setupSearchBar() {
        // 検索ボタンを押した際の処理
        keywordSearchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self!.keywordSearchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
    }
    
    /// AlertController表示の初期設定
    private func setupAlertController() {
        // 通知が来た場合にAlertControllerを表示する
        viewModel.output?.selectedDataObserver
            .filterNil()
            .subscribe(onNext: { [weak self] data in
                // AlertControllerの表示
                let alertController = self!.createAlert(title: "\(data.title)", message: "追加しますか？", isCancel: true)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    // Realmに登録
                    self!.viewModel.saveData() { [weak self] error in
                        if let error = error {
                            // エラーの場合はアラートを表示
                            alertController.dismiss(animated: true)
                            let alertController = self!.createAlert(title: error.localizedDescription, message: "他の場所を選択してください。", isCancel: false)
                            let okAction = UIAlertAction(title: "はい", style: .default)
                            alertController.addAction(okAction)
                            self!.present(alertController, animated: true)
                            
                        } else {
                            // 正常に終了した場合は、MainVCに戻る
                            alertController.dismiss(animated: true)
                            self!.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                alertController.addAction(okAction)
                self!.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    /// AlertControllerを作成する
    /// - Parameter title: Controllerに表示するタイトル
    /// - Parameter massage: Controllerに表示するメッセージ
    /// - Parameter isCancel: キャセルボタンをつけるか否か
    /// - Returns: 表示するAlertController
    private func createAlert(title: String, message: String, isCancel: Bool) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if isCancel {
            // キャンセルボタン追加
            let cancelButton = UIAlertAction(title: "いいえ", style: .cancel)
            alertController.addAction(cancelButton)
        }
        
        return alertController
    }
    
}
