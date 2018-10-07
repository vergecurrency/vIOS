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

    var pinCount: Int {
        get {
            UserDefaults.standard.register(defaults: ["wallet.pinCount": 6])
            return UserDefaults.standard.integer(forKey: "wallet.pinCount")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "wallet.pinCount")
        }
    }
    
    // User wants to use tor or not.
    var useTor: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "wallet.useTor")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "wallet.useTor")
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
            // Make sure wallet amount never gets less then zero.
            var correctNewValue = newValue.doubleValue
            if newValue.doubleValue < 0.0 {
                correctNewValue = 0.0
            }

            UserDefaults.standard.set(correctNewValue, forKey: "wallet.amount")

            NotificationCenter.default.post(name: .didChangeWalletAmount, object: nil)
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

    // Get transactions for core date.
    func getTransactions(offset: Int = 0, limit: Int = 10) -> [Transaction] {
        // TODO: For now we fetch them from an example json file.
        if let path = Bundle.main.path(forResource: "transactions", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return try JSONDecoder().decode([Transaction].self, from: data)
            } catch {
                return []
            }
        }

        return []
    }
    
    func reset() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
