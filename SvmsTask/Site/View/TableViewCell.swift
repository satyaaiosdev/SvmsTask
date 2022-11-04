//
//  TableViewCell.swift
//  SvmsTask
//
//  Created by Satyaa Akana on 03/11/22.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var titleLbl          : UILabel!
    @IBOutlet weak var contentLicenceLbl : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(item: Item) {
        titleLbl.text = "TITLE: \(item.title ?? "")"
        contentLicenceLbl.text = "LICENCE: \(item.content_license ?? "")"
    }
}
