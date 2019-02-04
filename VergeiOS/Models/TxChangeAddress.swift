//
// Created by Swen van Zanten on 15/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct TxChangeAddress: Decodable {

    public let isChange: Bool
    public let coin: String
    public let publicKeys: [String]
    public let type: String
    public let version: String
    public let path: String
    public let walletId: String
    public let createdOn: Int64
    public let network: String
    public let address: String
    public let _id: String

}
