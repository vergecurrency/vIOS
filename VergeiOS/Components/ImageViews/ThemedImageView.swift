//
// Created by Swen van Zanten on 2019-05-29.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import UIKit

class ThemedImageView: UIImageView {

    var themeImage: UIImage? {
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.image = self.themeImage
    }

}
