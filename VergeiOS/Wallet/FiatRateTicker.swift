//
//  FiatRateTicker.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

class FiatRateTicker {
    
    public static let shared = FiatRateTicker()

    private var started: Bool = false
    private var interval: Timer?

    var statisicsClient: RatesClient = RatesClient()
    var rateInfo: FiatRate?

    init () {
        // TODO: Move to event manager.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeCurrency),
            name: .didChangeCurrency,
            object: nil
        )
    }
    
    // Start the fiat rate ticker.
    func start() {
        if started {
            return
        }

        if !ApplicationRepository.default.setup {
            return
        }
        
        fetch()
        
        interval = Timer.scheduledTimer(withTimeInterval: Constants.fetchRateTimeout, repeats: true) { timer in
            self.fetch()
        }
        
        started = true
        print("Fiat rate ticker started...")
    }
    
    // Stop the price ticker.
    func stop() {
        interval?.invalidate()
        started = false

        print("Fiat rate ticker stopped...")
    }
    
    // Fetch statistics from the API and notify all absorbers.
    @objc private func fetch() {
        print("Fetching new stats")
        statisicsClient.infoBy(currency: ApplicationRepository.default.currency) { info in
            self.rateInfo = info

            print("Fiat ratings received, posting notification")
            NotificationCenter.default.post(name: .didReceiveFiatRatings, object: self.rateInfo)
        }
    }
    
    @objc private func didChangeCurrency(_ notification: Notification) {
        DispatchQueue.main.async {
            print("Currency changed 💰")
            self.fetch()
        }
    }

}
