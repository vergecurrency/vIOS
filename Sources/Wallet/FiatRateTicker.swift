//
//  FiatRateTicker.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

class FiatRateTicker {

    private var started: Bool = false
    private var interval: Timer?

    var applicationRepository: ApplicationRepository!
    var statisicsClient: RatesClient!
    var rateInfo: FiatRate?

    init (applicationRepository: ApplicationRepository, statisicsClient: RatesClient) {
        self.applicationRepository = applicationRepository
        self.statisicsClient = statisicsClient
    }

    // Start the fiat rate ticker.
    func start() {
        if started || !applicationRepository.setup {
            return
        }

        fetch()

        interval = Timer.scheduledTimer(withTimeInterval: Constants.fetchRateTimeout, repeats: true) { _ in
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
    @objc func fetch() {
        print("Fetching new stats")
        statisicsClient.infoBy(currency: applicationRepository.currency) { info in
            self.rateInfo = info

            print("Fiat ratings received, posting notification")
            NotificationCenter.default.post(name: .didReceiveFiatRatings, object: self.rateInfo)
        }
    }

}
