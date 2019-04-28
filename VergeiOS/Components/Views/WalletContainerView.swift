//
//  WalletContainerView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/03/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class WalletContainerView: UIView {

    let gl = CAGradientLayer()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.setColor()
        
        self.gl.locations = [0.0, 1.0]
        self.gl.frame = rect
        
        self.layer.insertSublayer(self.gl, at: 0)
    }
    
    func setColor() {
        let colorTop = ThemeManager.shared.backgroundTopColor().cgColor
        let colorBottom = ThemeManager.shared.backgroundBottomColor().cgColor
        
        self.gl.colors = [colorTop, colorBottom]
    }

}
