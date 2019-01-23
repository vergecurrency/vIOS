//
//  UIColor+Default.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIColor {
    static func primaryDark() -> UIColor {
        return UIColor(named: "PrimaryDark") ?? .blue
    }
    
    static func primaryLight() -> UIColor {
        return UIColor(named: "PrimaryLight") ?? .blue
    }
    
    static func secondaryDark() -> UIColor {
        return UIColor(named: "SecondaryDark") ?? .blue
    }
    
    static func secondaryLight() -> UIColor {
        return UIColor(named: "SecondaryLight") ?? .blue
    }
    
    static func backgroundBlue() -> UIColor {
        return UIColor(named: "BackgroundBlue") ?? .blue
    }
    
    static func backgroundGrey() -> UIColor {
        return UIColor(named: "BackgroundGrey") ?? .blue
    }
    
    static func vergeGrey() -> UIColor {
        return UIColor(named: "VergeGrey") ?? .gray
    }
    
    static func vergeGreen() -> UIColor {
        return UIColor(named: "VergeGreen") ?? .green
    }
    
    static func vergeRed() -> UIColor {
        return UIColor(named: "VergeRed") ?? .red
    }
}
