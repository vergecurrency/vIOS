//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct AddressInfo: Decodable {

    public let network: String
    public let path: String
    public let isChange: Bool
    public let coin: String
    public let _id: String?
    public let type: String
    public let createdOn: Int
    public let version: String
    public let publicKeys: [String]
    public let address: String
    public let walletId: String
    public let hasActivity: Bool?

}

extension AddressInfo {
    public var createdOnDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(createdOn))
    }
}
