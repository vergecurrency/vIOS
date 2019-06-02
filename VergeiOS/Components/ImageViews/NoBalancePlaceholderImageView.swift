//
//  NoBalancePlaceholderImageView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 29/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class NoBalancePlaceholderImageView: ThemedImageView {
    override var defaultImage: UIImage {
        get {
            return UIImage(named: "NoBalancePlaceholder")!
        }
        set {}
    }
    override var moonImage: UIImage {
        get {
            return UIImage(named: "NoBalancePlaceholderMoonMode")!
        }
        set {}
    }
}
