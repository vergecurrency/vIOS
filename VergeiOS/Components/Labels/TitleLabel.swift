//
//  TitleLabel.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class TitleLabel: UILabel {

    override func layoutSubviews() {
        super.layoutSubviews()

        self.setColors()
    }

    func setColors() {
        self.textColor = ThemeManager.shared.secondaryDark()
    }

}
