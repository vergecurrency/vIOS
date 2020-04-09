//
// Created by Swen van Zanten on 10/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct WalletID: Decodable {
        enum CodingKeys: String, CodingKey {
            case identifier = "walletId"
        }

        let identifier: String
    }
}
