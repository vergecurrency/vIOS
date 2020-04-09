//
// Created by Swen van Zanten on 09/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct WalletJoinErrorResponse: Decodable {
        enum Error: String {
            case WalletNotFound = "WALLET_NOT_FOUND"
            case CopayerRegistered = "COPAYER_REGISTERED"
        }

        let code: String
        let message: String

        var error: WalletJoinErrorResponse.Error? {
            WalletJoinErrorResponse.Error.init(rawValue: self.code)
        }

        func getError() -> NSError {
            NSError(domain: code, code: 500)
        }
    }
}
