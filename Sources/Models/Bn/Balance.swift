//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

extension Bn {
    struct Balance: Decodable {
        let confirmed: UInt64
        let unconfirmed: UInt64
        let balance: UInt64
    }
}
