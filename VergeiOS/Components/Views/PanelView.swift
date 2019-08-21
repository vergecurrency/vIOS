//
//  PanelView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable class PanelView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 5.0
    @IBInspectable var shadowOpacity: Float = 0.15
    @IBInspectable var shadowRadius: CGFloat = 15

    var shadowLayer: CAShapeLayer?

    open override func awakeFromNib() {
        super.awakeFromNib()

        self.themeable = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundColor = ThemeManager.shared.backgroundWhite()

        if self.shadowLayer == nil {
            self.shadowLayer = CAShapeLayer()
            self.shadowLayer!.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
            self.shadowLayer!.fillColor = self.backgroundColor?.cgColor

            self.shadowLayer!.shadowColor = UIColor.darkGray.cgColor
            self.shadowLayer!.shadowPath = self.shadowLayer!.path
            self.shadowLayer!.shadowOffset = CGSize.zero
            self.shadowLayer!.shadowOpacity = self.shadowOpacity
            self.shadowLayer!.shadowRadius = self.shadowRadius

            self.layer.insertSublayer(self.shadowLayer!, at: 0)
        }

        self.layer.cornerRadius = self.cornerRadius
    }

    override func updateColors() {
        super.updateColors()

        self.shadowLayer?.removeFromSuperlayer()
        self.shadowLayer = nil

        self.layoutSubviews()
    }
}
