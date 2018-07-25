//
//  ImageKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ImageKey: KeyboardKey {
    init(image: UIImage) {
        super.init(label: "")
        self.image = image
    }
}
