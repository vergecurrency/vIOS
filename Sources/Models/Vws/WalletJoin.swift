//
// Created by Swen van Zanten on 09/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct WalletJoin: Decodable {
        struct Error: DecodableError {
            var status: String
            
            enum Code: String, Decodable {
                case WalletNotFound = "WALLET_NOT_FOUND"
                case CopayerRegistered = "COPAYER_REGISTERED"
            }

            let code: Code
            let message: String
        }

        let copayerId: String
        let wallet: WalletInfo
    }
}
