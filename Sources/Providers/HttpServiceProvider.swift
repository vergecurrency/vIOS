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
        container.register(TorClient.self) { r in
            return TorClient(applicationRepository: r.resolve(ApplicationRepository.self)!)
        }.inObjectScope(.container)

        container.register(RatesClient.self) { r in
            return RatesClient(torClient: r.resolve(TorClient.self)!)
        }.inObjectScope(.container)
    }

}
