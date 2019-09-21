//
//  UIExtension.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(font: UIFont, textColor: UIColor) {
        self.init()
        self.textColor = textColor
        self.backgroundColor = .clear
        self.font = font
        self.numberOfLines = 0
    }
}
