//
// Created by Swen van Zanten on 09/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct AddressInfo: Decodable {
        let network: String
        let path: String
        let isChange: Bool
        let coin: String
        let _id: String?
        let type: String
        let createdOn: Int
        let version: String
        let publicKeys: [String]
        let address: String
        let walletId: String
        let hasActivity: Bool?

        public var createdOnDate: Date {
            return Date(timeIntervalSince1970: TimeInterval(self.createdOn))
        }
    }
}
