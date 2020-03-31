//
//  ReceiveCardImageView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 02/06/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class ReceiveCardImageView: CardImageView {

    override var themeImageName: String {
        return ThemeManager.shared.currentTheme.receiveCardImage
    }

}
