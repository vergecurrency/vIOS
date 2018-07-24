//
//  KeyboardKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class KeyboardKey: NSObject {
    var label: String = ""
    var value: Any? = nil
    var image: UIImage?
    
    init(label: String, value: Any? = nil) {
        self.label = label
        self.value = value
    }
}
