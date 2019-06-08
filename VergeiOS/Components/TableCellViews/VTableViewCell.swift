//
//  VTableViewCell.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class VTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setColors()
    }

    func setColors() {
        self.textLabel?.textColor = ThemeManager.shared.secondaryDark()
        self.detailTextLabel?.textColor = ThemeManager.shared.primaryLight()
    }
}
