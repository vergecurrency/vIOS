//
// Created by Swen van Zanten on 14/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class ThemeManager {

    static let shared = ThemeManager()

    func initialize(withWindow window: UIWindow) {
        UITabBar.appearance().layer.borderWidth = 0
        UITabBar.appearance().layer.borderColor = UIColor.clear.cgColor
        UITabBar.appearance().clipsToBounds = true

        window.tintColor = UIColor.primaryLight()
    }

}
