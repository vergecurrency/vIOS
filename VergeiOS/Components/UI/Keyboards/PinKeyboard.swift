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
            NumberKey(number: 2),
            NumberKey(number: 3),
            NumberKey(number: 4),
            NumberKey(number: 5),
            NumberKey(number: 6),
            NumberKey(number: 7),
            NumberKey(number: 8),
            NumberKey(number: 9),
            EmptyKey(),
            NumberKey(number: 0),
            BackKey()
        ]
    }
}
