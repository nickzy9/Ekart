//
//  CategoryCell.swift
//  Ekart
//
//  Created by Aniket on 9/22/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(_ isChild: Bool = false, name: String,
                   isOpen: Bool? = false, hasChild: Bool = false) {
        titleLabel.text = name
        iconView.isHidden = !hasChild
        
        if isChild {
            titleLabel.textColor = .headyGray
            titleLabel.font = UIFont.systemFont(ofSize: CGFloat(Global.fontSize.medium))
        } else {
            titleLabel.textColor = .headyText
            titleLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(Global.fontSize.big))
        }
        updateIconState(isOpen ?? false)
    }
    
    func updateIconState(_ isOpen: Bool) {
        iconView.image = isOpen ?  #imageLiteral(resourceName: "iconUp") : #imageLiteral(resourceName: "iconDown")
    }
}
