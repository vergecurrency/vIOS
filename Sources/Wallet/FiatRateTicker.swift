//
//  FiatRateTicker.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class FiatRateTicker: TickerProtocol {
    private let applicationRepository: ApplicationRepository
    private let statisicsClient: RatesClient
    private let log: Logger

    private var started: Bool = false
    private var interval: Timer?

    init (applicationRepository: ApplicationRepository, statisicsClient: RatesClient, log: Logger) {
        self.applicationRepository = applicationRepository
        self.statisicsClient = statisicsClient
        self.log = log
    }

    // Start the fiat rate ticker.
    func start() {
        if self.started {
            return self.log.notice("fiat ticker requested to start when already started")
        }

        if !self.applicationRepository.setup {
            return self.log.notice("fiat ticker requested to start before application received setup status")
        }

        self.tick()

        self.interval = Timer.scheduledTimer(withTimeInterval: Constants.fetchRateTimeout, repeats: true) { _ in
            self.tick()
        }

        self.started = true
        self.log.info("fiat ticker started")
    }

    // Stop the price ticker.
    func stop() {
        self.interval?.invalidate()
        self.started = false

        self.log.info("fiat ticker stopped")
    }

    // Fetch statistics from the API and notify all absorbers.
    func tick() {
        self.log.info("fiat rate ticker fetching rates")

        self.statisicsClient.infoBy(currency: self.applicationRepository.currency) { info in
            self.applicationRepository.latestRateInfo = info

            self.log.info("fiat rate ticker received rates")

            NotificationCenter.default.post(name: .didReceiveFiatRatings, object: info)
        }
    }

}
