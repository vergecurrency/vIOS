//
//  AddressErrorView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 22/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit

class AddressErrorView: UIView {

    @IBOutlet weak var errorLabel: UILabel!
    
    override func updateColors() {
        self.backgroundColor = ThemeManager.shared.currentTheme.backgroundGrey
    }

}
