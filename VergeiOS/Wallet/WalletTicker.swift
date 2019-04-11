//
// Created by Swen van Zanten on 17/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

class WalletTicker {

    private var client: WalletClient!
    private var applicationRepository: ApplicationRepository!
    private var transactionManager: TransactionManager!
    
    private var started: Bool = false
    private var interval: Timer?

    init(client: WalletClient, applicationRepository: ApplicationRepository, transactionManager: TransactionManager) {
        self.client = client
        self.applicationRepository = applicationRepository
        self.transactionManager = transactionManager
    }

    public func start() {
        if started {
            return
        }

        if !applicationRepository.setup {
            return
        }

        fetchWalletAmount()
        fetchTransactions()

        interval = Timer.scheduledTimer(withTimeInterval: Constants.fetchWalletTimeout, repeats: true) { timer in
            self.fetchWalletAmount()
            self.fetchTransactions()
        }

        started = true
        print("Wallet ticker started...")
    }

    // Stop the price ticker.
    func stop() {
        interval?.invalidate()
        interval = nil
        started = false

        print("Wallet ticker stopped...")
    }

    private func fetchWalletAmount() {
        print("Fetching wallet amount")

        client.getBalance { error, info in
            if let info = info {
                self.applicationRepository.amount = info.availableAmountValue
            }
        }
    }

    // Fetch statistics from the API and notify all absorbers.
    private func fetchTransactions() {
        print("Fetching new transactions")

        self.transactionManager.sync(limit: 10) { transactions in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)
        }
    }
}
