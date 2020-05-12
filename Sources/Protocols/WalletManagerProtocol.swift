//
//  Created by Swen van Zanten on 26/10/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Promises

protocol WalletManagerProtocol {
    func getWallet() -> Promise<Vws.WalletStatus>
    func getStatus() -> Promise<Vws.WalletStatus>
    func scanWallet() -> Promise<Bool>
}
