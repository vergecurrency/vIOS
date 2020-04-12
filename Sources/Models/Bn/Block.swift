//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

extension Bn {
    struct Block: Decodable {
        let _id: String
        let chain: String
        let network: String
        let hash: String
        let height: UInt64
        let version: UInt64
        let size: UInt64
        let merkleRoot: String
        let time: String
        let timeNormalized: String
        let nonce: UInt64
        let bits: UInt64
        let previousBlockHash: String
        let nextBlockHash: String
        let reward: UInt64
        let transactionCount: UInt64
        let confirmations: UInt64
    }
}
