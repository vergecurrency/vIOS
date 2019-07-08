//
// Created by Swen van Zanten on 2019-05-29.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import UIKit

class ThemedImageView: UIImageView {

    var themeImage: UIImage? {
        return nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func updateColors() {
        self.image = self.themeImage
    }
}
