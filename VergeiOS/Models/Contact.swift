//
//  Address.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct Contact: Decodable {
    
    public var name: String = ""
    public var address: String = ""
    
}

extension Contact {
    
    public func isValid() -> Bool {
        var valid = false
        
        if (name.trimmingCharacters(in: .whitespaces).count > 0 &&
            address.trimmingCharacters(in: .whitespaces).count > 0) {
            valid = AddressValidator.validate(address: address)
        }
        
        return valid
    }
    
}
