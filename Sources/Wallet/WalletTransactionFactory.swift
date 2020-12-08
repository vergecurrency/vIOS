//
// Created by Swen van Zanten on 24-08-18.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import Promises

class WalletTransactionFactory {

    enum CurrencySwitch {
        case XVG
        case FIAT
    }

    var currency = CurrencySwitch.XVG
    var amount: NSNumber = 0.0
    var fiatAmount: NSNumber = 0.0
    var address: String = ""
    var memo: String = ""
    var fiatCurrency: String

    internal typealias ListernerCallback = (WalletTransactionFactory) -> Void
    
    private let ratesClient: RatesClient!
    internal var listeners: [ListernerCallback] = []

    init(ratesClient: RatesClient, fiatCurrency: String) {
        self.ratesClient = ratesClient
        self.fiatCurrency = fiatCurrency
    }
    
    func currentAmount () -> NSNumber {
        return self.currency == .XVG ? self.amount : self.fiatAmount
    }
    
    func setBy(fiatCurrency: String) -> Promise<WalletTransactionFactory> {
        self.fiatCurrency = fiatCurrency

        return self.update()
    }

    func setBy(amount: NSNumber) -> Promise<WalletTransactionFactory> {
        if self.currency == .XVG {
            self.amount = amount

            return self.update()
        } else {
            self.fiatAmount = amount

            return self.updateAmount()
        }
    }

    func updateAmount() -> Promise<WalletTransactionFactory> {
        return self.ratesClient.infoBy(currency: self.fiatCurrency).then { rate in
            self.amount = NSNumber(value: self.fiatAmount.doubleValue / rate.price)

            self.callListeners()

            return Promise {
                return self
            }
        }
    }

    func update() -> Promise<WalletTransactionFactory> {
        if self.currency == .FIAT {
            return self.updateAmount()
        }

        return self.ratesClient.infoBy(currency: self.fiatCurrency).then { rate in
            self.fiatAmount = NSNumber(value: self.amount.doubleValue * rate.price)

            self.callListeners()

            return Promise {
                return self
            }
        }
    }

    func updated(listener: @escaping ListernerCallback) {
        self.listeners.append(listener)
    }
    
    func reset() -> Promise<WalletTransactionFactory> {
        self.amount = 0.0
        self.fiatAmount = 0.0
        self.address = ""
        self.memo = ""

        return self.update()
    }

    internal func callListeners() {
        for listener in self.listeners {
            listener(self)
        }
    }
}
