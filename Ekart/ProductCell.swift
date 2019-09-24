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
    
    var rankType = RankType.none
    var product: CategoryProduct? {
        didSet {
            if let product = product {
                self.selectionStyle = .none
                backView.layer.borderColor = UIColor.lightGray.cgColor
                backView.layer.borderWidth = 1
                backView.layer.cornerRadius = 3
                
                titleLabel.text = product.name
                
                let sortedVariants = product.variants.sorted(by: { $0.price < $1.price })
                
                descriptionLabel.text = ""
                
                if let variant = sortedVariants.first {
                    descriptionLabel.text = "Available from \(variant.price)"
                }
                
                countView.isHidden = rankType == .none
                
                switch rankType {
                case .share:
                    countLabel.text = "\(product.shares ?? 0)"
                case .views:
                    countLabel.text = "\(product.viewCount ?? 0)"
                case .orders:
                    countLabel.text = "\(product.orderCount ?? 0)"
                case .none:
                    break
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
