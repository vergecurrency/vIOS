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

    var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = backgroundColor?.cgColor

            shadowLayer.shadowColor = UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize.zero
            shadowLayer.shadowOpacity = shadowOpacity
            shadowLayer.shadowRadius = shadowRadius

            layer.insertSublayer(shadowLayer, at: 0)
        }

        layer.cornerRadius = cornerRadius
        backgroundColor = .clear
    }
}
