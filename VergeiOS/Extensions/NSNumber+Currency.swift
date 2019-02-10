//
//  NSNumber+Currency.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

extension NSNumber {

    func toCurrency(currency: String = ApplicationRepository.default.currency, fractDigits: Int = 2, floating: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if floating == false {
            formatter.minimumFractionDigits = fractDigits
        }
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
        return toCurrency(currency: ApplicationRepository.default.currency, fractDigits: fractDigits)
    }
    
    func toXvgCurrency(fractDigits: Int? = nil) -> String {
        var fractDigits = fractDigits

        if fractDigits == nil {
            fractDigits = Constants.maximumFractionDigits

            if self.doubleValue > 99 {
                fractDigits = 6
            }

            if self.doubleValue > 999 {
                fractDigits = 4
            }

            if self.doubleValue > 9999 {
                fractDigits = 2
            }
        }

        return toCurrency(currency: "XVG", fractDigits: fractDigits!)
    }

    func toBlankCurrency(fractDigits: Int = 2, floating: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if floating == false { // Freeze fractDigits number
            formatter.minimumFractionDigits = fractDigits
        }
        formatter.maximumFractionDigits = fractDigits
        formatter.currencyCode = ""
        formatter.currencySymbol = ""

        // Remove extra symbol space
        return "\(formatter.string(from: self)!)"
    }
}
