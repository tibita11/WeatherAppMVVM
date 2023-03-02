//
//  TableViewHeaderView.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/02.
//

import UIKit

protocol TableViewHeaderViewDelegate {
    func editAction(sender: UIButton)
}

class TableViewHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    var delegate: TableViewHeaderViewDelegate?
    
    func setup(headerTitle: String, isHidden: Bool = true, delegate: TableViewHeaderViewDelegate? = nil, editButtonTitle: String? = nil) {
        editButton.layer.cornerRadius = 15
        editButton.layer.masksToBounds = true
        
        headerLabel.text = headerTitle
        editButton.isHidden = isHidden
        editButton.setTitle("", for: .normal)
        
        if let title = editButtonTitle {
            editButton.setTitle(title, for: .normal)
        }
        
        self.delegate = delegate
    }
    
    @IBAction func editAction(_ sender: Any) {
        // 処理はMainVCに委任する
        guard let delegate = delegate, let sender = sender as? UIButton else { return }
        delegate.editAction(sender: sender)
    }
    
}
