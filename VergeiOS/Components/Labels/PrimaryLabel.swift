//
//  PrimaryLabel.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class PrimaryLabel: TitleLabel {

    override func setColors() {
        self.textColor = ThemeManager.shared.primaryLight()
    }

}
