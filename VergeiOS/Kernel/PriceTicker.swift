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
    
    // Start the price ticker.
    func start() {
        if started {
            return
        }

        self.fetchStats()
        
        self.interval = setInterval(60 * 5) {
            self.fetchStats()
        }
        
        started = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeCurrency), name: .didChangeCurrency, object: nil)
    }
    
    // Stop the price ticker.
    func stop() {
        interval?.invalidate()
    }
    
    // Fetch statistics from the API and notify all absorbers.
    private func fetchStats() {
        StatisicsAPIClient.shared.infoBy(currency: WalletManager.default.currency) { info in
            self.xvgInfo = info
            
            NotificationCenter.default.post(name: .didReceiveStats, object: self.xvgInfo)
        }
    }
    
    @objc private func didChangeCurrency(_ notification: Notification) {
        DispatchQueue.main.async {
            self.fetchStats()
        }
    }

}
