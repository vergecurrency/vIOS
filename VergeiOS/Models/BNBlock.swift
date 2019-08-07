//
//  BNBlock.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

struct BNBlock: Decodable {
    public let _id: String
    public let chain: String
    public let network: String
    public let hash: String
    public let height: UInt64
    public let version: UInt64
    public let size: UInt64
    public let merkleRoot: String
    public let time: String
    public let timeNormalized: String
    public let nonce: UInt64
    public let bits: UInt64
    public let previousBlockHash: String
    public let nextBlockHash: String
    public let reward: UInt64
    public let transactionCount: UInt64
    public let confirmations: UInt64
}
