//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class HttpServiceProvider: ServiceProvider {

    override func boot() {
        // Start the tor client
        container.resolve(TorClient.self)?.start()
    }

    override func register() {
        container.register(TorClientProtocol.self) { r in
            TorClient(applicationRepository: r.resolve(ApplicationRepository.self)!)
        }.inObjectScope(.container)

        container.register(TorClient.self) { r in
            r.resolve(TorClientProtocol.self) as! TorClient
        }

        container.register(RatesClient.self) { r in
            return RatesClient(torClient: r.resolve(TorClient.self)!)
        }.inObjectScope(.container)
    }

}