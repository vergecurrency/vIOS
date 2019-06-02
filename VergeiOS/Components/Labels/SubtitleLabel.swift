//
//  SubtitleLabel.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class SubtitleLabel: TitleLabel {

    override func setColors() {
        self.textColor = ThemeManager.shared.primaryDark()
    }

}
