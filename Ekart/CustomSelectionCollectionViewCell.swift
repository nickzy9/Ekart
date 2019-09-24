//
//  CustomSelectionCollectionViewCell.swift
//  Ekart
//
//  Created by Aniket on 24/09/2019.
//  Copyright © 2019 Heady. All rights reserved.
//

import UIKit

class CustomSelectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
    }
    
    func setView() {
        self.backView.layer.cornerRadius = 5
        self.backView.layer.borderColor = UIColor.headyGray.cgColor
        self.backView.layer.borderWidth = 1
    }

    
    override var isSelected: Bool {
        didSet {
            backView.backgroundColor = isSelected ? .headyBlue : .headyWhite
        }
    }
}
