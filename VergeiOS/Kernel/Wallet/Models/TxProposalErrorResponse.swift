//
// Created by Swen van Zanten on 2019-01-01.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

public struct TxProposalErrorResponse: Decodable {

    public enum Error: String {
        case BadSignatures = "BAD_SIGNATURES"
    }

    public let code: String
    public let message: String

}

public extension TxProposalErrorResponse {

    public var error: TxProposalErrorResponse.Error? {
        return TxProposalErrorResponse.Error.init(rawValue: code)
    }

}
