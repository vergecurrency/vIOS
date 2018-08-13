//
//  SelectorButton.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable class SelectorButton: UIButton {

    var labelLabel: UILabel?
    var valueLabel: UILabel?
    
    @IBInspectable var borderWidth: Int = 2
    @IBInspectable var borderColor: UIColor = UIColor.vergeGrey()
    
    @IBInspectable private var label: String = ""
    @IBInspectable private var value: String = ""
    
    @IBInspectable var titleColor: UIColor {
        get {
            return UIColor.secondaryLight()
        }
        set {
            self.labelLabel?.textColor = newValue
        }
    }
    
    @IBInspectable var valueColor: UIColor {
        get {
            return UIColor.secondaryDark()
        }
        set {
            self.labelLabel?.textColor = newValue
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        let borderRect = CGRect(x: rect.minX, y: rect.height - CGFloat(borderWidth), width: rect.width, height: CGFloat(borderWidth))
        let border: CALayer = CALayer(layer: self.layer)
        border.frame = borderRect
        border.backgroundColor = self.borderColor.cgColor
        
        self.layer.addSublayer(border)
        
        // Max width needs to be more dynamic..
        let maxWidth = rect.width - (8.0 + 38.0 + 8.0)
        let labelRect = CGRect(x: rect.minX, y: rect.minY, width: maxWidth, height: 14.0)
        
        self.labelLabel = UILabel(frame: labelRect)
        self.labelLabel?.text = label
        self.labelLabel?.font = UIFont.avenir(size: 14).medium()
        self.labelLabel?.textColor = self.titleColor
        
        self.addSubview(self.labelLabel!)
        
        let valueRect = CGRect(x: rect.minX, y: rect.minY + 19.0, width: maxWidth, height: 22.0)
        
        self.valueLabel = UILabel(frame: valueRect)
        self.valueLabel?.text = value
        self.valueLabel?.font = UIFont.avenir(size: 22).demiBold()
        self.valueLabel?.textColor = self.valueColor
        self.valueLabel?.adjustsFontSizeToFitWidth = true
        self.valueLabel?.minimumScaleFactor = 0.0
        
        self.addSubview(self.valueLabel!)
    }
}
