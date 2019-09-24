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
    
    var category: CategoryDetail? {
        didSet {
            if let category = category {
                iconView.isHidden = !category.hasChild
                var space = ""
                for _ in 0...category.level {
                    space = space + "   "
                }
                titleLabel.text = space + category.name.trimmingCharacters(in: .whitespaces)
                updateIconState(category.isOpen)
            }
        }
    }
    
    func updateIconState(_ isOpen: Bool) {
        iconView.image = isOpen ?  #imageLiteral(resourceName: "iconUp") : #imageLiteral(resourceName: "iconDown")
    }
}
