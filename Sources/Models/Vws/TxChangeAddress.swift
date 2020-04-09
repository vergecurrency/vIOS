//
// Created by Swen van Zanten on 15/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct TxChangeAddress: Decodable {
        let isChange: Bool
        let coin: String
        let publicKeys: [String]
        let type: String
        let version: String
        let path: String
        let walletId: String
        let createdOn: Int64
        let network: String
        let address: String
        let _id: String
    }
}
