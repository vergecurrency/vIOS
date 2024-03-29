//
// Created by Swen van Zanten on 2019-05-29.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import UIKit

class ThemedImageView: UIImageView {

    var themeImageName: String {
        return ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func updateColors() {
        self.image = UIImage(named: self.themeImageName)
    }
}
