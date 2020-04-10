//
// Created by Swen van Zanten on 10/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension NSError {
    convenience init(_ message: String) {
        self.init(domain: message, code: 0)
    }
}
