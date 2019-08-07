//
//  BlockchainServiceProvider.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

class BlockchainServiceProvider: ServiceProvider {

    override func register() {
        container.register(BitcoreNodeClientProtocol.self) { r in
            return BitcoreNodeClient(
                baseUrl: Constants.bnEndpoint,
                torClient: r.resolve(TorClient.self)!
            )
        }

        container.register(TransactionFactoryProtocol.self) { _ in
            return TransactionFactory()
        }
    }

}
