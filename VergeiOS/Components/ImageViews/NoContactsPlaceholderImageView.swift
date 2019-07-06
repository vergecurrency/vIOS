//
//  NoContactsPlaceholderImageView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 29/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class NoContactsPlaceholderImageView: ThemedImageView {
    
    override var themeImage: UIImage {
        return ThemeManager.shared.currentTheme.noContactsPlaceholderImage
    }
    
}
