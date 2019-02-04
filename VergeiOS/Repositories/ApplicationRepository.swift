//
//  ApplicationRepository.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import KeychainSwift

class ApplicationRepository {

    static let `default` = ApplicationRepository()

    private let keychain = KeychainSwift(keyPrefix: "verge_")
    private let userDefaults = UserDefaults.standard

    // Is the wallet already setup?
    var setup: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.state.setup")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.state.setup")
        }
    }
    
    // Store the wallet pin in the app key chain.
    var pin: String {
        get {
            return keychain.get("wallet.pin") ?? ""
        }
        set {
            keychain.set(newValue, forKey: "wallet.pin")
        }
    }

    var pinCount: Int {
        get {
            userDefaults.register(defaults: ["wallet.pinCount": 6])
            return userDefaults.integer(forKey: "wallet.pinCount")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.pinCount")
        }
    }
    
    // User wants to use tor or not.
    var useTor: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.useTor")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.useTor")
        }
    }
    
    // Store the selected wallet currency. Defaults to USD.
    // TODO: String used for now until better solution.
    var currency: String {
        get {
            return userDefaults.string(forKey: "wallet.currency") ?? "USD"
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.currency")
        }
    }
    
    var amount: NSNumber {
        get {
            return NSNumber(value: userDefaults.double(forKey: "wallet.amount"))
        }
        set {
            // Make sure wallet amount never gets less then zero.
            var correctNewValue = newValue.doubleValue
            if newValue.doubleValue < 0.0 {
                correctNewValue = 0.0
            }

            userDefaults.set(correctNewValue, forKey: "wallet.amount")

            NotificationCenter.default.post(name: .didChangeWalletAmount, object: nil)
        }
    }

    var localAuthForWalletUnlock: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.localAuth.unlockWallet")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.localAuth.unlockWallet")
        }
    }

    var localAuthForSendingXvg: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.localAuth.sendingXvg")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.localAuth.sendingXvg")
        }
    }

    var mnemonic: [String]? {
        get {
            var mnemonic = [String]()

            for index in 0..<12 {
                guard let word = keychain.get("mnemonic.word.\(index)") else {
                    return nil
                }
                mnemonic.append(word)
            }

            return mnemonic
        }
        set {
            guard let mnemonic = newValue else {
                for index in 0..<12 {
                    keychain.delete("mnemonic.word.\(index)")
                }
                return
            }

            for (index, word) in mnemonic.enumerated() {
                keychain.set(word, forKey: "mnemonic.word.\(index)")
            }
        }
    }

    var passphrase: String? {
        get {
            return keychain.get("wallet.passphrase")
        }
        set {
            if let passphrase = newValue {
                keychain.set(passphrase, forKey: "wallet.passphrase")
            } else {
                keychain.delete("wallet.passphrase")
            }
        }
    }

    var walletServiceUrl: String {
        get {
            return keychain.get("wallet.service.url") ?? Constants.bwsEndpoint
        }
        set {
            keychain.set(newValue, forKey: "wallet.service.url")
        }
    }

    var walletId: String? {
        get {
            return keychain.get("wallet.id")
        }
        set {
            if let walletId = newValue {
                keychain.set(walletId, forKey: "wallet.id")
            } else {
                keychain.delete("wallet.id")
            }
        }
    }

    var walletName: String? {
        get {
            return keychain.get("wallet.name")
        }
        set {
            if let walletName = newValue {
                keychain.set(walletName, forKey: "wallet.name")
            } else {
                keychain.delete("wallet.name")
            }
        }
    }

    var walletSecret: String? {
        get {
            return keychain.get("wallet.secret")
        }
        set {
            if let walletSecret = newValue {
                keychain.set(walletSecret, forKey: "wallet.secret")
            } else {
                keychain.delete("wallet.secret")
            }
        }
    }

    var deviceToken: String? {
        get {
            return userDefaults.string(forKey: "deviceToken")
        }
        set {
            userDefaults.set(newValue, forKey: "deviceToken")
        }
    }
    
    func reset() {
        TransactionManager.shared.removeAll()
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefaults.synchronize()
        keychain.clear()
    }
}
