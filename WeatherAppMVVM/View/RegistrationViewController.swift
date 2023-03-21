//
//  RegistrationViewController.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class RegistrationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    /// RxDataSources - dataSource
    let dataSource = RxTableViewSectionedReloadDataSource<RegistrationTableViewSectionModel>(configureCell: {
        (dataSource, tableView, indexPath, item) in
        
        switch item {
        case .defaultsType(let defaultsData):
            // CellType - defaultsType
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultsCell", for: indexPath) as! DefaultsTableViewCell
            // 初期化
            cell.isUserInteractionEnabled = true
            cell.backgroundColor = .systemBackground
            // 詳細設定
            cell.titleLabel.text = defaultsData.type.title
            cell.titleImage.image = UIImage(systemName: defaultsData.type.image)
            cell.accessoryType = .disclosureIndicator

            if dataSource[RegistrationTableViewSection.registerdLocation.number].items.count >= 3 {
                // DBに登録されている数が5以上の場合は選択不可
                cell.isUserInteractionEnabled = false
                cell.backgroundColor = .systemGray6
            }
            return cell
            
        case .locationType(let locationData):
            // CellType - locationType
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationTableViewCell
            // 詳細設定
            cell.titleLabel.text = locationData.title
            cell.latitudeLabel.text = "緯度: \(String(locationData.latitude))"
            cell.longitudeLabel.text = "経度: \(String(locationData.longitude))"
            return cell
        }

    }, canEditRowAtIndexPath: { (dataSource, index) in
        // registerdLocationのみ編集モードを可能にする
        if index.section == RegistrationTableViewSection.registerdLocation.number { return true }
        return false
    })
    
    let viewModel = RegistrationViewModel()
    
    let disposeBag = DisposeBag()
    /// TableViewHeaderViewのeditButtonTitleを判定
    var editButtonTitle: String {
        if tableView.isEditing { return "完了" }
        return "並び替え・削除"
    }
    /// 現在位置取得の際に表示するView
    var updatingView: UpdatingView!
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatingView = UpdatingView(frame: self.view.frame)
    }
    
    
    // MARK: - Action
    
    /// 初期設定
    private func setup() {
        let input = RegistrationViewInput(itemDeleted: tableView.rx.itemDeleted, itemMoved: tableView.rx.itemMoved)
        viewModel.setupMainView(input: input)
        
        // 位置情報で権限エラーが出た場合のアラート表示
        viewModel.output?.locationErrorObserver
            .subscribe(onNext: { [weak self] error in
                self!.showPermissionAlert(error: error)
            })
            .disposed(by: disposeBag)
        
        // 位置情報の開始から終了までViewを表示
        viewModel.output?.isUpdatingObserver
            .subscribe(onNext: { [weak self] bool in
                if bool {
                    // Viewを表示
                    self!.updatingView.startIndicator()
                    self!.view.addSubview(self!.updatingView)
                } else {
                    // Viewを非表示
                    self!.updatingView.stopIndicator()
                    self!.updatingView.removeFromSuperview()
                }
            })
            .disposed(by: disposeBag)
        
        // 重複チェック後の処理を表示
        viewModel.isDeplicateObserver
            .subscribe(onNext: { [weak self] isDeplicate in
                guard let self = self else { return }
                if let index = isDeplicate.0 {
                    // 重複がある場合
                    if let rootVC = self.navigationController?.viewControllers.first as? WeatherViewController {
                        rootVC.setViewControllers(page: index)
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    // 重複がない場合
                    let alertController = UIAlertController(title: "\(isDeplicate.1.title)", message: "追加しますか？", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "はい", style: .default) { _ in
                        // realmに保存する
                        self.viewModel.addData(object: isDeplicate.1)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    let cancelAction = UIAlertAction(title: "いいえ", style: .cancel)
                    
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// TableViewに関する初期設定
    private func setupTableView() {
        tableView.register(UINib(nibName: "DefaultsTableViewCell", bundle: nil), forCellReuseIdentifier: "defaultsCell")
        tableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "locationCell")
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        // delegate設定
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        // TableViewバインドする
        viewModel.output?.itemObserver
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        // セルをタップした際の処理
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self!.tableView.deselectRow(at: indexPath, animated: true)
                guard let item = self?.dataSource[indexPath] else { return }
                
                switch item {
                case .defaultsType(let defaultType):
                    switch defaultType.type {
                    case .placeAndFacility:
                        // 検索画面に遷移
                        let keywordSearchVC = KeywordSearchViewController(nibName: "KeywordSearchViewController", bundle: nil)
                        self!.navigationController?.pushViewController(keywordSearchVC, animated: true)
                    case .searchCurrentLocation:
                        // 現在位置を取得する処理
                        self!.viewModel.gettingCurrentLocation()
                    }
                default: break
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    /// 位置情報の権限エラーに関するアラート生成
    private func showPermissionAlert(error: LocationError) {
        let alert = UIAlertController(title: "位置情報", message: error.localizedDescription, preferredStyle: .alert)
        
        if error == .authorityError {
            // 権限エラーの場合は設定画面を開くボタンを追加
            let goToSetting = UIAlertAction(title: "設定に移動", style: .default) { _ in
                // 設定画面を開く処理
                guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingUrl) {
                    UIApplication.shared.open(settingUrl)
                }
            }
            alert.addAction(goToSetting)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    
}


// MARK: - UITableViewDelegate
extension RegistrationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // カスタマイズヘッダー設定
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as? TableViewHeaderView else {
            return nil
        }
        
        let headerTitle = dataSource[section].model.title
        // 登録地点以外のヘッダー
        if dataSource[section].model != .registerdLocation {
            headerView.setup(headerTitle: headerTitle)
            return headerView
        }

        headerView.setup(headerTitle: headerTitle, isHidden: false, delegate: self, editButtonTitle: self.editButtonTitle)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        // 同セクション内のみ並び替え可能
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        }
        return sourceIndexPath
    }
}


extension RegistrationViewController: TableViewHeaderViewDelegate {
    func editAction(sender: UIButton) {
        // 編集状態を変更
        self.tableView.isEditing = !self.tableView.isEditing
        // headerViewのeditButtonを変更
        sender.setTitle(self.editButtonTitle, for: .normal)
    }
    
}
