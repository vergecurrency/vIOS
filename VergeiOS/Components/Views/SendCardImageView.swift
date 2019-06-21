//
//  SendCardImageView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 02/06/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class SendCardImageView: CardImageView {
    
    override var themeImage: UIImage {
        get {
            return ThemeManager.shared.currentTheme.sendCardImage
        }
        set {}
    }
    
}
