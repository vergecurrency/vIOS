//
//  FiatRateTicker.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

class FiatRateTicker: TickerProtocol {
    private var started: Bool = false
    private var interval: Timer?
    private var applicationRepository: ApplicationRepository!
    private var statisicsClient: RatesClient!

    init (applicationRepository: ApplicationRepository, statisicsClient: RatesClient) {
        self.applicationRepository = applicationRepository
        self.statisicsClient = statisicsClient
    }

    // Start the fiat rate ticker.
    func start() {
        if self.started || !self.applicationRepository.setup {
            return
        }

        self.tick()

        self.interval = Timer.scheduledTimer(withTimeInterval: Constants.fetchRateTimeout, repeats: true) { _ in
            self.tick()
        }

        self.started = true
        print("Fiat rate ticker started...")
    }

    // Stop the price ticker.
    func stop() {
        self.interval?.invalidate()
        self.started = false

        print("Fiat rate ticker stopped...")
    }

    // Fetch statistics from the API and notify all absorbers.
    func tick() {
        print("Fetching new stats")
        self.statisicsClient.infoBy(currency: self.applicationRepository.currency) { info in
            self.applicationRepository.latestRateInfo = info

            print("Fiat ratings received, posting notification")
            NotificationCenter.default.post(name: .didReceiveFiatRatings, object: info)
        }
    }

}
