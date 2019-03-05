//
//  SelectorButton.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable class SelectorButton: UIButton {

    var drawn = false

    var labelLabel: UILabel?
    var valueLabel: UILabel?
    
    @IBInspectable var borderWidth: Double = 0.5
    @IBInspectable var borderColor: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1)
    
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

        if drawn {
            return
        }

        drawSubviews(rect: rect)
        drawn = true
    }

    private func drawSubviews(rect: CGRect) {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }

        let borderRect = CGRect(
            x: rect.minX,
            y: rect.height - CGFloat(borderWidth),
            width: rect.width,
            height: CGFloat(borderWidth)
        )
        let border: CALayer = CALayer(layer: self.layer)
        border.frame = borderRect
        border.backgroundColor = self.borderColor.cgColor

        self.layer.addSublayer(border)

        // Max width needs to be more dynamic..
        let labelRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width - 8.0, height: 14.0)

        self.labelLabel = UILabel(frame: labelRect)
        self.labelLabel?.text = label
        self.labelLabel?.font = UIFont.avenir(size: 14).medium()
        self.labelLabel?.textColor = self.titleColor

        self.addSubview(self.labelLabel!)

        let valueRect = CGRect(x: rect.minX, y: rect.minY + 19.0, width: rect.width - 8.0, height: 22.0)

        self.valueLabel = UILabel(frame: valueRect)
        self.valueLabel?.text = value
        self.valueLabel?.font = UIFont.avenir(size: 16).demiBold()
        self.valueLabel?.textColor = self.valueColor
        self.valueLabel?.adjustsFontSizeToFitWidth = true
        self.valueLabel?.minimumScaleFactor = 0.8
        self.valueLabel?.lineBreakMode = .byTruncatingMiddle

        self.addSubview(self.valueLabel!)
    }
}
