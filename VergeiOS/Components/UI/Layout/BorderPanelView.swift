//
//  BorderPanelView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable class BorderPanelView: UIView {
    
    @IBInspectable var width: Int = 1
    @IBInspectable var borderColor: UIColor = UIColor.vergeGrey()

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let borderRect = CGRect(x: rect.minX, y: rect.height - CGFloat(width), width: rect.width, height: CGFloat(width))
        let border: CALayer = CALayer(layer: self.layer)
        border.frame = borderRect
        border.backgroundColor = self.borderColor.cgColor
        
        self.layer.addSublayer(border)
    }

}
