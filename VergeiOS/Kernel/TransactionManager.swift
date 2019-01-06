//
// Created by Swen van Zanten on 18/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

class TransactionManager {

    public static let shared = TransactionManager(
        walletClient: WalletClient.shared,
        transactionRepository: TransactionRepository()
    )

    private var walletClient: WalletClient!
    private var transactionRepository: TransactionRepository!

    public init (walletClient: WalletClient, transactionRepository: TransactionRepository) {
        self.walletClient = walletClient
        self.transactionRepository = transactionRepository
    }

    public var hasTransactions: Bool {
        return transactionRepository.all().count > 0
    }

    public func all(completion: @escaping (_ transactions: [TxHistory]) -> Void) {
        if !hasTransactions {
            sync { transactions in
                return completion(transactions)
            }
        }

        completion(transactionRepository.all().sorted { thule, thule2 in
            return thule.sortBy(txHistory: thule2)
        })
    }

    public func all(byAddress address: String) -> [TxHistory] {
        return transactionRepository.get(byAddress: address).sorted { thule, thule2 in
            return thule.sortBy(txHistory: thule2)
        }
    }

    public func sync(skip: Int = 0, limit: Int = 50, completion: @escaping (_ transactions: [TxHistory]) -> Void) {
        walletClient.getTxHistory(skip: skip, limit: limit) { transactions in
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
                return self.sync(skip: skip + 50, completion: completion)
            }

            completion(self.transactionRepository.all())
        }
    }
    
    public func remove(transaction: TxHistory) {
        transactionRepository.remove(tx: transaction)
    }

    public func removeAll() {
        transactionRepository.removeAll()
    }
}
