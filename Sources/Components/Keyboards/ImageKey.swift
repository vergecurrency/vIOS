//
//  ImageKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ImageKey: AbstractKey {
    init(image: UIImage) {
        super.init(label: "")
        self.image = image
    }

    override func styleKey(_ button: KeyboardButton) {
        button.setImage(self.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
    }
}
