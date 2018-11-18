//
//  NSNumber+Currency.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

extension NSNumber {

    func toCurrency(currency: String = ApplicationManager.default.currency, fractDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = fractDigits
        
        var suffix = ""
        if currency != "XVG" {
            formatter.currencyCode = currency
        } else {
            formatter.currencySymbol = ""
            suffix = " XVG"
        }
        
        // Remove extra symbol space
        return "\(formatter.string(from: self)!)\(suffix)"
    }
    
    func toPairCurrency(fractDigits: Int = 2) -> String {
        return toCurrency(currency: ApplicationManager.default.currency, fractDigits: fractDigits)
    }
    
    func toXvgCurrency(fractDigits: Int = 2) -> String {
        return toCurrency(currency: "XVG", fractDigits: fractDigits)
    }

    func toBlankCurrency(fractDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = fractDigits
        formatter.currencyCode = ""
        formatter.currencySymbol = ""

        // Remove extra symbol space
        return "\(formatter.string(from: self)!)"
    }
}
