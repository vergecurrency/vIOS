//
//  AbstractKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class AbstractKey: NSObject, KeyboardKey {
    var label: String = ""
    var value: Any? = nil
    var image: UIImage?
    var button: UIButton?
    
    init(label: String, value: Any? = nil) {
        self.label = label
        self.value = value
    }
    
    func styleKey(_ button: KeyboardButton) {}

    func getValue() -> Any? {
        return self.value
    }

    func setButton(_ button: UIButton) {
        self.button = button
    }
}
