//
// Created by Swen van Zanten on 13/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct TxProposalResponse: Decodable {
        let createdOn: UInt32?
        let coin: String
        let id: String
        let network: String
        let message: String?
        let inputs: [UnspentOutput]
        let fee: UInt64
        let status: String
        let creatorId: String
        let walletN: Int64
        let walletM: Int64
        let outputs: [TxOutput]
        let amount: UInt64
        let changeAddress: TxChangeAddress
        let walletId: String
        let requiredSignatures: Int64
        let version: Int64
        let excludeUnconfirmedUtxos: Bool
        let addressType: String
        let requiredRejections: Int64
        let outputOrder: [Int64]
        let inputPaths: [String]
    }
}
