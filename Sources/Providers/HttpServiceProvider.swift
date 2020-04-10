//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class HttpServiceProvider: ServiceProvider {

    override func boot() {
        if container.resolve(ApplicationRepository.self)?.setup ?? false {
            // Start the tor client
            container.resolve(TorClient.self)?.start()
        }
    }

    override func register() {
        container.register(TorClientProtocol.self) { r in
            TorClient(applicationRepository: r.resolve(ApplicationRepository.self)!, log: r.resolve(Logger.self)!)
        }.inObjectScope(.container)

        container.register(TorClient.self) { r in
            r.resolve(TorClientProtocol.self) as! TorClient
        }

        container.register(RatesClient.self) { r in
            return RatesClient(torClient: r.resolve(TorClient.self)!)
        }.inObjectScope(.container)
    }

}
