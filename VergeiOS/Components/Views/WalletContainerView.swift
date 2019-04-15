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
        let colorTop = UIColor(red: 0.39, green: 0.80, blue: 0.86, alpha: 1.0).cgColor
        let colorBottom = ThemeManager.shared.primaryLight().cgColor
        
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        gl.frame = rect
        
        self.layer.insertSublayer(gl, at: 0)
    }

}
