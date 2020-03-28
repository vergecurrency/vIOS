//
// Created by Swen van Zanten on 2019-01-21.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

public struct CreateAddressErrorResponse: Decodable {

    public enum Error: String {
        case MainAddressGapReached = "MAIN_ADDRESS_GAP_REACHED"
    }

    public let code: String
    public let message: String

}

public extension CreateAddressErrorResponse {

    var error: CreateAddressErrorResponse.Error? {
        CreateAddressErrorResponse.Error.init(rawValue: code)
    }

    func getError() -> NSError {
        NSError(domain: code, code: 500)
    }
}
