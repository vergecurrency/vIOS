//
//  LightBackgroundView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 15/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class LightBackgroundView: BackgroundView {

    override func setColors() {
        self.backgroundColor = ThemeManager.shared.backgroundWhite()
    }

}
