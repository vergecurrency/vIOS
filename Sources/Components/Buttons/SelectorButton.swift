//
//  SelectorButton.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable class SelectorButton: UIButton {

    @IBInspectable var label: String = ""
    @IBInspectable var value: String = ""
    @IBInspectable var usesSideLabelLayout: Bool = false {
        didSet {
            redraw()
        }
    }
    @IBInspectable var sideLabelX: CGFloat = 0 {
        didSet {
            redraw()
        }
    }
    @IBInspectable var sideLabelWidth: CGFloat = 130 {
        didSet {
            redraw()
        }
    }

    var drawn = false

    var labelLabel: UILabel?
    var valueLabel: UILabel?
    var border: CALayer?

    var borderWidth: Double = 0.5
    var borderColor: UIColor {
        return ThemeManager.shared.separatorColor()
    }

    var titleColor: UIColor {
        return ThemeManager.shared.secondaryLight()
    }

    var valueColor: UIColor {
        return ThemeManager.shared.secondaryDark()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func updateColors() {
        self.border?.backgroundColor = self.borderColor.cgColor
        self.labelLabel?.textColor = self.titleColor
        self.valueLabel?.textColor = usesSideLabelLayout ? .white : self.valueColor
        self.backgroundColor = usesSideLabelLayout ? .clear : ThemeManager.shared.backgroundGrey().withAlphaComponent(0.35)
        self.layer.cornerRadius = usesSideLabelLayout ? 0 : 8
        self.layer.borderWidth = usesSideLabelLayout ? 0 : 1
        self.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.22).cgColor
        self.layer.sublayers?
            .filter { $0.name == "SelectorInputFill" }
            .forEach { $0.removeFromSuperlayer() }

        if usesSideLabelLayout {
            redraw()
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

        self.layer.sublayers?
            .filter { $0.name == "SelectorInputFill" }
            .forEach { $0.removeFromSuperlayer() }

        if usesSideLabelLayout {
            drawSideLabelLayout(rect: rect)
            return
        }

        self.backgroundColor = ThemeManager.shared.backgroundGrey().withAlphaComponent(0.35)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.22).cgColor

        let inset: CGFloat = 12.0
        let borderRect = CGRect(
            x: rect.minX + inset,
            y: rect.height - CGFloat(borderWidth),
            width: rect.width - (inset * 2),
            height: CGFloat(borderWidth)
        )
        self.border = CALayer(layer: self.layer)
        self.border?.frame = borderRect
        self.border?.backgroundColor = self.borderColor.cgColor

        self.layer.addSublayer(self.border!)

        // Max width needs to be more dynamic..
        let labelRect = CGRect(x: rect.minX + inset, y: rect.minY + 5.0, width: rect.width - (inset * 2), height: 16.0)

        self.labelLabel = UILabel(frame: labelRect)
        self.labelLabel?.text = label
        self.labelLabel?.font = UIFont.avenir(size: 14).medium()
        self.labelLabel?.textColor = self.titleColor

        self.addSubview(self.labelLabel!)

        let valueRect = CGRect(x: rect.minX + inset, y: rect.minY + 24.0, width: rect.width - (inset * 2), height: 22.0)

        self.valueLabel = UILabel(frame: valueRect)
        self.valueLabel?.text = value
        self.valueLabel?.font = UIFont.avenir(size: 16).demiBold()
        self.valueLabel?.textColor = self.valueColor
        self.valueLabel?.adjustsFontSizeToFitWidth = true
        self.valueLabel?.minimumScaleFactor = 0.8
        self.valueLabel?.lineBreakMode = .byTruncatingMiddle

        self.addSubview(self.valueLabel!)
    }

    private func drawSideLabelLayout(rect: CGRect) {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 0
        self.layer.borderWidth = 0

        let inputX: CGFloat = 0
        let inputRect = CGRect(
            x: inputX,
            y: rect.minY + 18,
            width: rect.width - inputX,
            height: rect.height - 18
        )

        let inputLayer = CAGradientLayer()
        inputLayer.name = "SelectorInputFill"
        inputLayer.frame = inputRect
        inputLayer.cornerRadius = 10
        inputLayer.colors = [
            UIColor(rgb: 0x12071A).cgColor,
            UIColor(rgb: 0x28103F).cgColor,
            UIColor(rgb: 0x08030E).cgColor
        ]
        inputLayer.startPoint = CGPoint(x: 0, y: 0)
        inputLayer.endPoint = CGPoint(x: 1, y: 1)
        inputLayer.borderWidth = 1
        inputLayer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.34).cgColor
        self.layer.insertSublayer(inputLayer, at: 0)

        let labelRect = CGRect(x: rect.minX + 2, y: rect.minY, width: rect.width - 4, height: 16)
        self.labelLabel = UILabel(frame: labelRect)
        self.labelLabel?.text = label
        self.labelLabel?.font = UIFont.avenir(size: 12).demiBold()
        self.labelLabel?.textColor = ThemeManager.shared.primaryLight()
        self.labelLabel?.numberOfLines = 1
        self.labelLabel?.lineBreakMode = .byTruncatingTail
        self.labelLabel?.adjustsFontSizeToFitWidth = true
        self.labelLabel?.minimumScaleFactor = 0.78
        self.addSubview(self.labelLabel!)

        let valueRect = inputRect.insetBy(dx: 12, dy: 7)
        self.valueLabel = UILabel(frame: valueRect)
        self.valueLabel?.text = value
        self.valueLabel?.font = UIFont.avenir(size: 15).demiBold()
        self.valueLabel?.textColor = .white
        self.valueLabel?.adjustsFontSizeToFitWidth = true
        self.valueLabel?.minimumScaleFactor = 0.72
        self.valueLabel?.lineBreakMode = .byTruncatingMiddle
        self.addSubview(self.valueLabel!)
    }

    func redraw() {
        drawn = false
        self.setNeedsDisplay()
    }
}
