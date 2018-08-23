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
    
    // Store the selected wallet currency. Defaults to USD.
    // TODO: String used for now until better solution.
    var currency: String {
        get {
            return UserDefaults.standard.string(forKey: "wallet.currency") ?? "USD"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "wallet.currency")
        }
    }
    
    var amount: NSNumber {
        get {
            return NSNumber(value: UserDefaults.standard.double(forKey: "wallet.amount"))
        }
        set {
            UserDefaults.standard.set(newValue.doubleValue, forKey: "wallet.amount")
        }
    }

    var currentBalanceSlide: Int {
        get {
            return UserDefaults.standard.integer(forKey: "wallet.currentBalanceSlide")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "wallet.currentBalanceSlide")
        }
    }

    var localAuthForWalletUnlock: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "wallet.localAuth.unlockWallet")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "wallet.localAuth.unlockWallet")
        }
    }

    var localAuthForSendingXvg: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "wallet.localAuth.sendingXvg")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "wallet.localAuth.sendingXvg")
        }
    }
    
    func reset() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
