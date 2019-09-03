//
//  Font+Extensions.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI

extension Font {
    static func avenir(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        self.custom("Avenir Next", size: size).weight(weight)
    }
}
