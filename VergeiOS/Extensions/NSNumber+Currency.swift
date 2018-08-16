//
//  NSNumber+Currency.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 14-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

extension NSNumber {

    func toCurrency(currency: String = WalletManager.default.currency, fractDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = fractDigits
        
        if currency != "XVG" {
            formatter.currencyCode = currency
        } else {
            formatter.currencySymbol = "XVG"
        }
        
        // Remove extra symbol space
        return formatter.string(from: self)!
    }
    
}
