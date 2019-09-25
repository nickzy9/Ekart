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

extension UIView {
    func applyCard(_ shadow: CGFloat = 8) {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = shadow
        self.layer.shadowOpacity = 0.7
    }
    
    func showHideWithAnimation(show: Bool = true, duration: Double = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = show ? .moveIn : .reveal
        transition.subtype = show ? .fromTop : .fromBottom
        self.layer.add(transition, forKey: nil)
        self.isHidden = !show
    }
}
