//
//  VViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class VViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.statusBarStyle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setColors()
    }

    func setColors() {
        self.view.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
