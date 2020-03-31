//
//  CurrencySubscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

class CurrencySubscriber: Subscriber {
    private let fiatRateTicker: FiatRateTicker

    init(fiatRateTicker: FiatRateTicker) {
        self.fiatRateTicker = fiatRateTicker
    }

    @objc func didChangeCurrency(notification: Notification) {
        DispatchQueue.main.async {
            print("Currency changed 💰")

            self.fiatRateTicker.fetch()
        }
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        [
            .didChangeCurrency: #selector(didChangeCurrency(notification:))
        ]
    }
}
