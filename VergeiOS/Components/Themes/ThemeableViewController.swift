//
//  ThemeableViewController.swift
//  VergeiOS
//
//  Created by Ivan Manov on 03.07.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class ThemeableViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.statusBarStyle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateColors()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateColors),
                                               name: .didChangeTheme,
                                               object: nil)
    }
}

extension ThemeableViewController: Themeable {

    func updateColors() {
        self.view.backgroundColor = ThemeManager.shared.backgroundGrey()
        self.setNeedsStatusBarAppearanceUpdate()
    }

}
