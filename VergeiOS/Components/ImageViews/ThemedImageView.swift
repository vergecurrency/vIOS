//
// Created by Swen van Zanten on 2019-05-29.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import UIKit

class ThemedImageView: UIImageView {

    var defaultImage: UIImage? {
        return nil
    }
    var moonImage: UIImage? {
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.image = ThemeManager.shared.useMoonMode ? self.moonImage : self.defaultImage
    }

}
