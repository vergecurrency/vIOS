//
// Created by Swen van Zanten on 2019-01-01.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct TxProposalErrorResponse: Decodable {
        enum Error: String {
            case BadSignatures = "BAD_SIGNATURES"
        }

        let code: String
        let message: String

        var error: TxProposalErrorResponse.Error? {
            return TxProposalErrorResponse.Error.init(rawValue: self.code)
        }
    }

    // TODO: remove old error VWS response classes
//    struct TxProposalErrorResponse: Decodable {
//        enum Code: String, Decodable {
//            case BadSignatures = "BAD_SIGNATURES"
//        }
//
//        let code: Code
//        let message: String
//    }
}
