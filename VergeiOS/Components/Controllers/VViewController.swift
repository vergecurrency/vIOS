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
        return ThemeManager.shared.useDarkTheme ? .lightContent : .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: .themeChanged, object: nil)

        self.setColors()
    }

    func setColors() {
        self.view.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.setNeedsStatusBarAppearanceUpdate()
    }

    @objc func themeChanged(notification: Notification) {
        self.setColors()
    }
}
