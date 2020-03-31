//
// Created by Swen van Zanten on 17/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

class WalletTicker {

    private var client: WalletClientProtocol!
    private var applicationRepository: ApplicationRepository!
    private var transactionManager: TransactionManager!

    private var started: Bool = false
    private var interval: Timer?

    init(client: WalletClientProtocol, applicationRepository: ApplicationRepository, transactionManager: TransactionManager) {
        self.client = client
        self.applicationRepository = applicationRepository
        self.transactionManager = transactionManager
    }

    public func start() {
        if self.started {
            return
        }

        if !self.applicationRepository.setup {
            return
        }

        self.fetchWalletAmount()
        self.fetchTransactions()

        interval = Timer.scheduledTimer(withTimeInterval: Constants.fetchWalletTimeout, repeats: true) { _ in
            self.fetchWalletAmount()
            self.fetchTransactions()
        }

        self.started = true
        print("Wallet ticker started...")
    }

    // Stop the price ticker.
    func stop() {
        interval?.invalidate()
        interval = nil
        started = false

        print("Wallet ticker stopped...")
    }

    func tick() {
        self.fetchWalletAmount()
        self.fetchTransactions()
    }

    private func fetchWalletAmount() {
        print("Fetching wallet amount")

        client.getBalance { _, info in
            if let info = info {
                self.applicationRepository.amount = info.availableAmountValue
            }
        }
    }

    // Fetch statistics from the API and notify all absorbers.
    private func fetchTransactions() {
        print("Fetching new transactions")

        self.transactionManager.sync(limit: 10) { _ in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)
        }
    }
}
