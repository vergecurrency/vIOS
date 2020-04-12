//
// Created by Swen van Zanten on 17/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class WalletTicker: TickerProtocol {
    enum Error: Swift.Error {
        case NoWalletAmountInfo
    }

    private let client: WalletClientProtocol
    private let applicationRepository: ApplicationRepository
    private let transactionManager: TransactionManager
    private let log: Logger

    private var started: Bool = false
    private var interval: Timer?

    init(
        client: WalletClientProtocol,
        applicationRepository: ApplicationRepository,
        transactionManager: TransactionManager,
        log: Logger
    ) {
        self.client = client
        self.applicationRepository = applicationRepository
        self.transactionManager = transactionManager
        self.log = log
    }

    public func start() {
        if self.started {
            return self.log.notice("wallet ticker requested to start when already started")
        }

        if !self.applicationRepository.setup {
            return self.log.notice("wallet ticker requested to start before application received setup status")
        }

        self.tick()

        interval = Timer.scheduledTimer(withTimeInterval: Constants.fetchWalletTimeout, repeats: true) { _ in
            self.tick()
        }

        self.started = true
        self.log.info("wallet ticker started")
    }

    // Stop the price ticker.
    func stop() {
        interval?.invalidate()
        interval = nil
        started = false

        self.log.info("wallet ticker stopped")
    }

    func tick() {
        self.fetchWalletAmount()
        self.fetchTransactions()
    }

    private func fetchWalletAmount() {
        self.log.info("wallet ticker fetching wallet amount")

        client.getBalance { error, info in
            guard let info = info else {
                let error = error ?? Error.NoWalletAmountInfo
                return self.log.error("wallet ticker amount error: \(error.localizedDescription)")
            }

            self.applicationRepository.amount = info.availableAmountValue

            self.log.info("wallet ticker set wallet amount")
        }
    }

    // Fetch statistics from the API and notify all observers.
    private func fetchTransactions() {
        self.log.info("wallet ticker fetching transactions")

        self.transactionManager.sync(limit: 10) { _ in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)

            self.log.info("wallet ticker received transactions")
        }
    }
}
