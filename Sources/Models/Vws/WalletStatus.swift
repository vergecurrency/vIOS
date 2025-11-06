//
// Created by Swen van Zanten on 10/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct WalletStatus: Decodable {
        struct Error: DecodableError {
            var status: String
            
            enum Code: String, Decodable {
                case WalletNotFound = "WALLET_NOT_FOUND"
            }

            let code: Code
            let message: String
        }

        let pendingTxps: [TxProposalResponse]?
        let wallet: WalletInfo?
        let balance: WalletBalanceInfo?
    }
}
