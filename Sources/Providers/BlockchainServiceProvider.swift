//
//  BlockchainServiceProvider.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class BlockchainServiceProvider: ServiceProvider {

    override func register() {
        container.register(BitcoreNodeClientProtocol.self) { r in
            BitcoreNodeClient(
                baseUrl: Constants.bnEndpoint,
                httpSession: r.resolve(HttpSessionProtocol.self)!,
                log: r.resolve(Logger.self)!
            )
        }

        container.register(TransactionFactoryProtocol.self) { r in
            return TransactionFactory(log: r.resolve(Logger.self)!)
        }
    }

}
