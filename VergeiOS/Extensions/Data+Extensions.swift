//
// Created by Swen van Zanten on 19/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Data {
    public init?(fromHex: String) {
        let len = fromHex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = fromHex.index(fromHex.startIndex, offsetBy: i * 2)
            let k = fromHex.index(j, offsetBy: 2)
            let bytes = fromHex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}
