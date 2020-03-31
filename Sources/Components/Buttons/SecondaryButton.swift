//
//  SecondaryButton.swift
//  VergeiOS
//
//  Created by Ivan Manov on 07.07.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class SecondaryButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func updateColors() {
        self.imageView?.tintColor = ThemeManager.shared.secondaryLight()
    }

}
