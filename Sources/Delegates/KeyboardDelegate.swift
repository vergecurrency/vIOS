//
//  KeyboardDelegate.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

protocol KeyboardDelegate: class {
    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey)
}
