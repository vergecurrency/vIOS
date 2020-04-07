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
            return self.log.notice(LogMessage.WalletTickerStartTwice)
        }

        if !self.applicationRepository.setup {
            return self.log.notice(LogMessage.WalletTickerStartBeforeSetup)
        }

        self.tick()

        interval = Timer.scheduledTimer(withTimeInterval: Constants.fetchWalletTimeout, repeats: true) { _ in
            self.tick()
        }

        self.started = true
        self.log.notice(LogMessage.WalletTickerStarted)
    }

    // Stop the price ticker.
    func stop() {
        interval?.invalidate()
        interval = nil
        started = false

        self.log.notice(LogMessage.WalletTickerStopped)
    }

    func tick() {
        self.fetchWalletAmount()
        self.fetchTransactions()
    }

    private func fetchWalletAmount() {
        self.log.notice(LogMessage.WalletTickerFetchingWalletAmount)

        client.getBalance { error, info in
            guard let info = info else {
                return self.log.error(LogMessage.WalletTickerWalletAmountError(error ?? Error.NoWalletAmountInfo))
            }

            self.applicationRepository.amount = info.availableAmountValue

            self.log.notice(LogMessage.WalletTickerSetWalletAmount)
        }
    }

    // Fetch statistics from the API and notify all observers.
    private func fetchTransactions() {
        self.log.notice(LogMessage.WalletTickerFetchingTransactions)

        self.transactionManager.sync(limit: 10) { _ in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)

            self.log.notice(LogMessage.WalletTickerReceivedTransactions)
        }
    }
}
