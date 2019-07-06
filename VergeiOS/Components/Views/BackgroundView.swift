//
//  BackgroundView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func updateColors() {
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
    }
    
}
