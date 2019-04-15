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
    var border: CALayer?
    
    var borderWidth: Double = 0.5
    var borderColor: UIColor {
        return ThemeManager.shared.separatorColor()
    }
    
    @IBInspectable private var label: String = ""
    @IBInspectable private var value: String = ""
    
    var titleColor: UIColor {
        return ThemeManager.shared.secondaryLight()
    }
    
    var valueColor: UIColor {
        return ThemeManager.shared.secondaryDark()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: .themeChanged, object: nil)
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
        self.border = CALayer(layer: self.layer)
        self.border?.frame = borderRect
        self.border?.backgroundColor = self.borderColor.cgColor

        self.layer.addSublayer(self.border!)

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

    @objc func themeChanged(notification: Notification) {
        self.border?.backgroundColor = self.borderColor.cgColor
        self.labelLabel?.textColor = self.titleColor
        self.valueLabel?.textColor = self.valueColor
    }
}
