//
// Created by Swen van Zanten on 13/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct TxProposalResponse: Decodable {

    public let createdOn: UInt32?
    public let coin: String
    public let id: String
    public let network: String
    public let message: String?
    public let inputs: [UnspentOutput]
    public let fee: UInt64
    public let status: String
    public let creatorId: String
    public let walletN: Int64
    public let walletM: Int64
    public let outputs: [TxOutput]
    public let amount: UInt64
    public let changeAddress: TxChangeAddress
    public let walletId: String
    public let requiredSignatures: Int64
    public let version: Int64
    public let excludeUnconfirmedUtxos: Bool
    public let addressType: String
    public let requiredRejections: Int64
    public let outputOrder: [Int64]
    public let inputPaths: [String]

}
