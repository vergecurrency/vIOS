//
//  KeyboardButton.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 25-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class KeyboardButton: UIButton {

    var keyboardKey: KeyboardKey?

    override func layoutSubviews() {
        super.layoutSubviews()

        applyRetrowaveKeyStyle()
        contentEdgeInsets = .zero
        titleEdgeInsets = .zero
        imageEdgeInsets = .zero
        titleLabel?.frame = bounds.insetBy(dx: 2, dy: 0)
        titleLabel?.textAlignment = .center
    }

    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }

    private func applyRetrowaveKeyStyle() {
        guard !(keyboardKey is EmptyKey), bounds.width > 0, bounds.height > 0 else {
            return
        }

        let gradientName = "RetrowaveKeyGradient"
        layer.sublayers?
            .filter { $0.name == gradientName }
            .forEach { $0.removeFromSuperlayer() }

        backgroundColor = .clear
        tintColor = ThemeManager.shared.primaryLight()
        setTitleColor(.white, for: .normal)
        setTitleColor(ThemeManager.shared.primaryLight(), for: .highlighted)
        imageView?.tintColor = ThemeManager.shared.primaryLight()
        imageView?.contentMode = .center

        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.42).cgColor
        layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 0)
        clipsToBounds = false

        let insetBounds = bounds.insetBy(dx: 5, dy: 4)
        let gradient = CAGradientLayer()
        gradient.name = gradientName
        gradient.frame = insetBounds
        gradient.cornerRadius = 10
        gradient.colors = [
            UIColor(rgb: 0x12071A).cgColor,
            UIColor(rgb: 0x2A1044).cgColor,
            UIColor(rgb: 0x08030E).cgColor
        ]
        gradient.locations = [0.0, 0.55, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient, at: 0)
    }
}
