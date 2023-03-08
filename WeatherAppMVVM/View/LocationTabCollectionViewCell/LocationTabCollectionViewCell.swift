//
//  LocationTabCollectionViewCell.swift
//  WeatherAppMVVM
//
//  Created by 鈴木楓香 on 2023/03/08.
//

import UIKit

protocol LocationTabCollectionViewCellDelegate: AnyObject {
    /// PageViewControllerのページを移動する
    /// - Parameter to: ページ番号
    func moveCurrentPage(to page: Int)
}

class LocationTabCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    
    weak var delegate: LocationTabCollectionViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBAction func tapAction(_ sender: Any) {
        delegate.moveCurrentPage(to: self.tag)
    }
    
}
