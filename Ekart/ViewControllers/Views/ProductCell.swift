//
//  ProductCell.swift
//  Ekart
//
//  Created by Aniket on 9/22/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var isToShowRanking = false
    var product: CategoryProduct? {
        didSet {
            if let product = product {
                self.selectionStyle = .none
                backView.layer.cornerRadius = 3
                titleLabel.text = product.name
                
                // Sort to get lowest price variant
                let sortedVariants = product.variants.sorted(by: { $0.price < $1.price })
                if let variant = sortedVariants.first {
                    descriptionLabel.text = "Available from \(variant.price)"
                }
                // Show count view
                if isToShowRanking {
                    countView.backgroundColor = .headyRed
                    countView.isHidden = false
                    countLabel.text = "\(product.rankCount)"
                    countLabel.textColor = .headyWhite
                    return
                }
                countView.isHidden = true
            }
        }
    }
}
