//
//  TitleImageView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class SubtitleImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: .themeChanged, object: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.setColors()
    }

    func setColors() {
        self.tintColor = ThemeManager.shared.primaryDark()
    }

    @objc func themeChanged(notification: Notification) {
        self.setColors()
    }

}
