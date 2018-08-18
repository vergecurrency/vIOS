//
//  PriceTicker.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

class PriceTicker {
    
    public static let shared = PriceTicker()

    private var started: Bool = false
    private var interval: Timer?
    
    var xvgInfo: XvgInfo?

    init () {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeCurrency),
            name: .didChangeCurrency,
            object: nil
        )
    }
    
    // Start the price ticker.
    func start() {
        if started {
            return
        }

        if !WalletManager.default.setup {
            return
        }

        self.fetchStats()

        self.interval = setInterval(150) {
            self.fetchStats()
        }

        started = true
        print("Price ticker started...")
    }
    
    // Stop the price ticker.
    func stop() {
        interval?.invalidate()
        started = false

        print("Price ticker stopped...")
    }
    
    // Fetch statistics from the API and notify all absorbers.
    private func fetchStats() {
        print("Fetching new stats")
        StatisicsAPIClient.shared.infoBy(currency: WalletManager.default.currency) { info in
            self.xvgInfo = info

            print("Stats received, posting notification")
            NotificationCenter.default.post(name: .didReceiveStats, object: self.xvgInfo)
        }
    }
    
    @objc private func didChangeCurrency(_ notification: Notification) {
        DispatchQueue.main.async {
            print("Currency changed 💰")
            self.fetchStats()
        }
    }

}
