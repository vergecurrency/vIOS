//
// Created by Swen van Zanten on 09/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct CreateAddressError: Decodable {
        enum Error: String {
            case MainAddressGapReached = "MAIN_ADDRESS_GAP_REACHED"
        }

        let code: String
        let message: String

        var error: CreateAddressError.Error? {
            CreateAddressError.Error.init(rawValue: self.code)
        }

        func getError() -> NSError {
            NSError(domain: self.code, code: 500)
        }
    }
}
