//
//  KeyboardKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

protocol KeyboardKey {
    func styleKey(_ button: KeyboardButton)
    func getValue() -> Any?

    var button: UIButton? { get set }
    
    func isKind(of: AnyClass) -> Bool
    func setButton(_ button: UIButton)
}
