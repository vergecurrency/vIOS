//
//  CurrencySubscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class CurrencySubscriber: Subscriber {
    private let fiatRateTicker: TickerProtocol
    private let log: Logger

    init(fiatRateTicker: TickerProtocol, log: Logger) {
       
        self.fiatRateTicker = fiatRateTicker
        self.log = log
        super.init()
    }

    @objc func didChangeCurrency(notification: Notification) {
        DispatchQueue.main.async {
            let currencyName = (notification.object as? [String : String])?["name"] ?? "unknown"

            self.log.info("application currency changed to: \(currencyName)")

            self.fiatRateTicker.tick()
        }
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        [
            .didChangeCurrency: #selector(didChangeCurrency(notification:))
        ]
    }
}
