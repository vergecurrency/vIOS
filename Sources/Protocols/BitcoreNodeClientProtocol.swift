//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Promises

protocol BitcoreNodeClientProtocol {
    func send(rawTx: String) -> Promise<Bn.SendResponse>

    func block(byHash hash: String) -> Promise<Bn.Block>

    func transactions(byAddress address: String) -> Promise<[Bn.Transaction]>
    func unspendTransactions(byAddress address: String) -> Promise<[Bn.Transaction]>
    func balance(byAddress address: String) -> Promise<Bn.Balance>
}
