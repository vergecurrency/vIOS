//
//  BackgroundView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()

        self.setColors()
    }

    func setColors() {
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
    }
}
