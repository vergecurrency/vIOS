//
//  PanelView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable class PanelView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 10.0
    @IBInspectable var shadowOpacity: Float = 0.20
    @IBInspectable var shadowRadius: CGFloat = 16

    var shadowLayer: CAShapeLayer?

    open override func awakeFromNib() {
        super.awakeFromNib()

        self.themeable = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundColor = ThemeManager.shared.backgroundWhite()

        self.shadowLayer?.removeFromSuperlayer()

        self.shadowLayer = CAShapeLayer()
        self.shadowLayer!.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
        self.shadowLayer!.fillColor = self.backgroundColor?.cgColor
        self.shadowLayer!.strokeColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.32).cgColor
        self.shadowLayer!.lineWidth = 1

        self.shadowLayer!.shadowColor = ThemeManager.shared.primaryLight().cgColor
        self.shadowLayer!.shadowPath = self.shadowLayer!.path
        self.shadowLayer!.shadowOffset = CGSize.zero
        self.shadowLayer!.shadowOpacity = self.shadowOpacity
        self.shadowLayer!.shadowRadius = self.shadowRadius

        self.layer.insertSublayer(self.shadowLayer!, at: 0)

        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = 1
        self.layer.borderColor = ThemeManager.shared.separatorColor().cgColor
    }

    override func updateColors() {
        super.updateColors()

        self.shadowLayer?.removeFromSuperlayer()
        self.shadowLayer = nil

        self.layoutSubviews()
    }
}
