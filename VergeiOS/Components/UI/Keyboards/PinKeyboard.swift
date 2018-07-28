//
//  PinKeyboard.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PinKeyboard: Keyboard {
    override func charactersInOrder() -> [KeyboardKey] {
        return [
            NumberKey(number: 1),
            NumberKey(number: 2, subtitle: "ABC"),
            NumberKey(number: 3, subtitle: "DEF"),
            NumberKey(number: 4, subtitle: "GHI"),
            NumberKey(number: 5, subtitle: "JKL"),
            NumberKey(number: 6, subtitle: "MNO"),
            NumberKey(number: 7, subtitle: "PORS"),
            NumberKey(number: 8, subtitle: "TUV"),
            NumberKey(number: 9, subtitle: "WYXZ"),
            EmptyKey(),
            NumberKey(number: 0),
            BackKey()
        ]
    }
}
