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

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: .themeChanged, object: nil)

        self.setColors()
    }

    func setColors() {
        self.textColor = ThemeManager.shared.secondaryDark()
    }

    @objc func themeChanged(notification: Notification) {
        self.setColors()
    }

}
