//
// Created by Swen van Zanten on 17/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

class WalletTicker {

    public static let shared = WalletTicker()

    private var client: WalletClient!
    private var started: Bool = false
    private var interval: Timer?

    init(client: WalletClient = WalletClient.shared) {
        self.client = client
    }

    public func start() {
        if started {
            return
        }

        if !ApplicationRepository.default.setup {
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

        WalletClient.shared.getBalance { error, info in
            if let info = info {
                ApplicationRepository.default.amount = info.availableAmountValue
            }
        }
    }

    // Fetch statistics from the API and notify all absorbers.
    private func fetchTransactions() {
        print("Fetching new transactions")

        TransactionManager.shared.sync(limit: 10) { transactions in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)
        }
    }
}
