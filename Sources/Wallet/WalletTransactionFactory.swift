//
// Created by Swen van Zanten on 24-08-18.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

class WalletTransactionFactory {

    var amount: NSNumber = 0.0
    var fiatAmount: NSNumber = 0.0
    var address: String = ""
    var memo: String = ""
    var fiatCurrency: String? = nil

    private let ratesClient: RatesClient!

    init(ratesClient: RatesClient) {
        self.ratesClient = ratesClient
    }

    func setBy(currency: String, fiatCurrency: String, amount: NSNumber) {
        self.fiatCurrency = fiatCurrency

        if currency == "XVG" {
            self.amount = amount
        } else {
            self.fiatAmount = amount
        }

        self.update(currency: currency, fiatCurrency: fiatCurrency)
    }

    func update(currency: String, fiatCurrency: String? = nil) {
        self.fiatCurrency = fiatCurrency

        if fiatCurrency == nil {
            self.fiatCurrency = currency == "XVG" ? nil : currency
        }

        self.ratesClient.infoBy(currency: self.fiatCurrency ?? currency).then { rate in
            if currency == "XVG" {
                self.fiatAmount = NSNumber(value: self.amount.doubleValue * rate.price)

                return
            }

            self.amount = NSNumber(value: self.fiatAmount.doubleValue / rate.price)
        }
    }

}
