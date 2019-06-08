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
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.setColors()
    }

    func setColors() {
        self.tintColor = ThemeManager.shared.primaryDark()
    }

}
