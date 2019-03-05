//
//  BorderPanelView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable class BorderPanelView: UIView {
    
    @IBInspectable var width: CGFloat = 0.5
    @IBInspectable var borderColor: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.9, alpha: 1)

    @IBInspectable var top: Bool = true
    @IBInspectable var bottom: Bool = true
    @IBInspectable var left: Bool = true
    @IBInspectable var right: Bool = true

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        if top {
            addTopBorder(rect)
        }
        if bottom {
            addBottomBorder(rect)
        }
        if left {
            addLeftBorder(rect)
        }
        if right {
            addRightBorder(rect)
        }
    }

    func addTopBorder(_ rect: CGRect) {
        let borderRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: width
        )
        let border: CALayer = CALayer(layer: self.layer)
        border.frame = borderRect
        border.backgroundColor = self.borderColor.cgColor

        self.layer.addSublayer(border)
    }

    func addBottomBorder(_ rect: CGRect) {
        let borderRect = CGRect(
            x: rect.minX,
            y: rect.minY + (rect.height - CGFloat(width)),
            width: rect.width,
            height: width
        )
        let border: CALayer = CALayer(layer: self.layer)
        border.frame = borderRect
        border.backgroundColor = self.borderColor.cgColor

        self.layer.addSublayer(border)
    }

    func addLeftBorder(_ rect: CGRect) {
        let borderRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: width,
            height: rect.height
        )
        let border: CALayer = CALayer(layer: self.layer)
        border.frame = borderRect
        border.backgroundColor = self.borderColor.cgColor

        self.layer.addSublayer(border)
    }

    func addRightBorder(_ rect: CGRect) {
        let borderRect = CGRect(
            x: rect.minX + rect.width,
            y: rect.minY,
            width: width,
            height: rect.height
        )
        let border: CALayer = CALayer(layer: self.layer)
        border.frame = borderRect
        border.backgroundColor = self.borderColor.cgColor

        self.layer.addSublayer(border)
    }

}
