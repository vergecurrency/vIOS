//
//  WalletManager.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import KeychainSwift

class WalletManager {
    
    static let `default` = WalletManager()
    
    // Is the wallet already setup?
    var setup: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "wallet.state.setup")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "wallet.state.setup")
        }
    }
    
    // Store the wallet pin in the app key chain.
    var pin: String {
        get {
            return KeychainSwift().get("wallet.pin") ?? ""
        }
        set {
            KeychainSwift().set(newValue, forKey: "wallet.pin")
        }
    }
    
}
