//
//  Color+Extensions.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/09/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
    init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(
            UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        )
    }

    init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    static func vergeGrey() -> Color {
        return Color("VergeGrey")
    }

    static func vergeGreen() -> Color {
        return Color("VergeGreen")
    }

    static func vergeRed() -> Color {
        return Color("VergeRed")
    }

    static func backgroundGrey() -> Color {
        return Color("BackgroundGrey")
    }

    static func backgroundBlue() -> Color {
        return Color("BackgroundBlue")
    }

    static func backgroundWhite() -> Color {
        return Color("BackgroundWhite")
    }

    static func primaryDark() -> Color {
        return Color("PrimaryDark")
    }

    static func primaryLight() -> Color {
        return Color("PrimaryLight")
    }

    static func secondaryDark() -> Color {
        return Color("SecondaryDark")
    }

    static func secondaryLight() -> Color {
        return Color("SecondaryLight")
    }

    static func blueGradient() -> [Color] {
        return [
            Color("BlueTop"),
            Color("BlueBottom")
        ]
    }
}
