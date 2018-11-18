//
// Created by Swen van Zanten on 18/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import CoreStore

class TransactionRepository {
    public func get(byAddress address: String) -> [TxHistory] {
        let entities = CoreStore.fetchAll(From<TransactionType>().where(\.address == address))
        var transactions: [TxHistory] = []

        for entity in entities ?? [] {
            transactions.append(transform(entity: entity))
        }

        return transactions
    }

    func all() -> [TxHistory] {
        let entities = CoreStore.fetchAll(From<TransactionType>())
        var transactions: [TxHistory] = []

        for entity in entities ?? [] {
            transactions.append(transform(entity: entity))
        }

        return transactions
    }

    func put(tx: TxHistory) {
        var entity: TransactionType? = nil
        if let existingEntity = CoreStore.fetchOne(From<TransactionType>().where(\.txid == tx.txid)) {
            entity = existingEntity
        }

        do {
            let _ = try CoreStore.perform(synchronous: { transaction -> Bool in
                if entity == nil {
                    entity = transaction.create(Into<TransactionType>())
                } else {
                    entity = transaction.edit(entity)
                }

                entity?.txid = tx.txid
                entity?.action = tx.action
                entity?.amount = tx.amount
                entity?.fees = tx.fees
                entity?.time = tx.time
                entity?.confirmations = tx.confirmations
                entity?.feePerKb = tx.feePerKb
                entity?.address = tx.address
                entity?.createdOn = tx.createdOn ?? 0

                return transaction.hasChanges
            })
        } catch {
            print(error.localizedDescription)
        }
    }

    func remove(tx: TxHistory) {
        let entity = CoreStore.fetchOne(From<TransactionType>().where(\.txid == tx.txid))

        do {
            let _ = try CoreStore.perform(synchronous: { transaction -> Bool in
                transaction.delete(entity)

                return transaction.hasChanges
            })
        } catch {
            print(error.localizedDescription)
        }
    }

    private func transform(entity: TransactionType?) -> TxHistory {
        let transaction = TxHistory(
            txid: entity?.txid ?? "",
            action: entity?.action ?? "moved",
            amount: entity?.amount ?? 0,
            fees: entity?.fees ?? 0,
            time: entity?.time ?? 0,
            confirmations: entity?.confirmations ?? 0,
            feePerKb: entity?.feePerKb ?? 0,
            inputs: [],
            outputs: [],
            savedAddress: entity?.address ?? "",
            createdOn: entity?.createdOn
        )

        return transaction
    }
}
