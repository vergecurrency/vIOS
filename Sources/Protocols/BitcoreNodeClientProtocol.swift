//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Promises

protocol BitcoreNodeClientProtocol {
    func send(rawTx: String) -> Promise<BNSendResponse>

    func block(byHash hash: String) -> Promise<BNBlock>

    func transactions(byAddress address: String) -> Promise<[BNTransaction]>
    func unspendTransactions(byAddress address: String) -> Promise<[BNTransaction]>
    func balance(byAddress address: String) -> Promise<BNBalance>
}
