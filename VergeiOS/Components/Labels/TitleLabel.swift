//
//  TitleLabel.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class TitleLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.updateColors()
    }

    override func updateColors() {
        self.textColor = ThemeManager.shared.secondaryDark()
    }

}
