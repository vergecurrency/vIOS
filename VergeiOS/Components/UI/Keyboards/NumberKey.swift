//
//  NumberKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class NumberKey: KeyboardKey {
    init(number: Int) {
        super.init(label: "\(number)", value: number)
    }
}
