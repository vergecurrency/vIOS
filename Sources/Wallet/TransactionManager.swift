//
// Created by Swen van Zanten on 18/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

class TransactionManager {
    private var walletClient: WalletClientProtocol!
    private var transactionRepository: TransactionRepository!
    private var isSyncing = false
    private var pendingSyncCompletions = [([Vws.TxHistory]) -> Void]()
    private var lastRootSyncCompletedAt: Date?

    public init (walletClient: WalletClientProtocol, transactionRepository: TransactionRepository) {
        self.walletClient = walletClient
        self.transactionRepository = transactionRepository
    }

    public var hasTransactions: Bool {
        return transactionRepository.all().count > 0
    }

    public func all(completion: @escaping (_ transactions: [Vws.TxHistory]) -> Void) {
        sync { transactions in
            completion(transactions.sorted { thule, thule2 in
                return thule.sortBy(txHistory: thule2)
            })
        }
    }

    private func sortedTransactions() -> [Vws.TxHistory] {
        return transactionRepository.all().sorted { thule, thule2 in
            return thule.sortBy(txHistory: thule2)
        }
    }

    public func all(byAddress address: String) -> [Vws.TxHistory] {
        return transactionRepository.get(byAddress: address).sorted { thule, thule2 in
            return thule.sortBy(txHistory: thule2)
        }
    }

    public func sync(skip: Int = 0, limit: Int = 50, completion: @escaping (_ transactions: [Vws.TxHistory]) -> Void) {
        let isRootSync = skip == 0

        if isRootSync && isSyncing {
            pendingSyncCompletions.append(completion)
            return
        }

        if isRootSync {
            isSyncing = true
        }

        walletClient.getTxHistory(skip: skip, limit: limit) { transactions, _ in
            if skip == 0 {
                self.transactionRepository.removeAll()
            }

            var txids = [String]()
            let transactions = transactions.filter { tx in
                if txids.contains(tx.txid) && tx.category == .Moved {
                    return false
                }

                txids.append(tx.txid)
                return true
            }

            for transaction in transactions {
                self.transactionRepository.remove(tx: transaction)
                self.transactionRepository.put(tx: transaction)
            }

            if transactions.count == 50 {
                return self.sync(skip: skip + 50, completion: { sorted in
                    if isRootSync {
                        self.finishSync(sortedTransactions: sorted, completion: completion)
                    } else {
                        completion(sorted)
                    }
                })
            }

            let sorted = self.sortedTransactions()
            if isRootSync {
                self.finishSync(sortedTransactions: sorted, completion: completion)
            } else {
                completion(sorted)
            }
        }
    }

    public func syncIfStale(maxAge: TimeInterval, limit: Int = 50, completion: @escaping (_ transactions: [Vws.TxHistory]) -> Void) {
        if !needsSync(maxAge: maxAge) {
            completion(sortedTransactions())
            return
        }

        sync(limit: limit, completion: completion)
    }

    public func needsSync(maxAge: TimeInterval) -> Bool {
        guard let lastRootSyncCompletedAt = lastRootSyncCompletedAt else {
            return true
        }

        return Date().timeIntervalSince(lastRootSyncCompletedAt) >= maxAge
    }

    private func finishSync(sortedTransactions: [Vws.TxHistory], completion: @escaping (_ transactions: [Vws.TxHistory]) -> Void) {
        isSyncing = false
        lastRootSyncCompletedAt = Date()
        let completions = [completion] + pendingSyncCompletions
        pendingSyncCompletions.removeAll()
        completions.forEach { $0(sortedTransactions) }
    }

    public func remove(transaction: Vws.TxHistory) {
        transactionRepository.remove(tx: transaction)
    }

    public func removeAll() {
        transactionRepository.removeAll()
    }
}
