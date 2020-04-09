//
// Created by Swen van Zanten on 09/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct WalletJoin: Decodable {
        let copayerId: String
        let wallet: WalletInfo
    }
}
