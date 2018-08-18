//
//  PlaceholderView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 18-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PlaceholderView: BalanceSlide {

    var roundLayer: CAShapeLayer? = nil

    override func draw(_ rect: CGRect) {
        DispatchQueue.main.async {
            if (self.roundLayer == nil) {
                self.roundLayer = CAShapeLayer.init()

                let layerRect = CGRect(
                    x: rect.origin.x + 23,
                    y: rect.origin.y + 3,
                    width: rect.width - 46,
                    height: rect.height - 6
                )

                let path = UIBezierPath(roundedRect: layerRect, cornerRadius: 5)
                self.roundLayer?.path = path.cgPath
                self.roundLayer?.lineWidth = 2.5
                self.roundLayer?.lineDashPattern = [4, 4]

                self.layer.addSublayer(self.roundLayer!)
            }

            self.roundLayer?.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
            self.roundLayer?.backgroundColor = UIColor.clear.cgColor
            self.roundLayer?.fillColor = UIColor.clear.cgColor
        }
    }
}
