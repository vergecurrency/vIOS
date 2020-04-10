//
// Created by Swen van Zanten on 09/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

struct Vws {
    // Vws namespace
}

protocol DecodableError: Decodable {
    var message: String { get }
    var error: Error { get }
}

extension DecodableError {
    var error: Error {
        return NSError(domain: self.message, code: 500)
    }
}