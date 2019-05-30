//
//  UnlockBackgroundImageView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 30/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class UnlockBackgroundImageView: ThemedImageView {
    override var defaultImage: UIImage {
        get {
            return UIImage(named: "UnlockBackground")!
        }
        set {}
    }
    override var moonImage: UIImage {
        get {
            return UIImage(named: "UnlockBackgroundMoonMode")!
        }
        set {}
    }
}
