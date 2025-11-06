//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class HttpServiceProvider: ServiceProvider {

    override func boot() {
        if self.container.resolve(ApplicationRepository.self)?.setup ?? false {
            // Start the tor client
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.container.resolve(TorClientProtocol.self)?.start()
//            }
        }
    }

//    override func register() {
//        self.container.register(TorClientProtocol.self) { r in
//            TorClient(applicationRepository: r.resolve(ApplicationRepository.self)!, log: r.resolve(Logger.self)!)
//        }.inObjectScope(.container)
//
//        self.container.register(TorClient.self) { r in
//            r.resolve(TorClientProtocol.self) as! TorClient
//        }
//
//        self.container.register(HttpSessionProtocol.self) { r in
//            return HiddenHttpSession(hiddenClient: r.resolve(TorClient.self)!)
//        }
//
//        self.container.register(RatesClient.self) { r in
//            return RatesClient(httpSession: r.resolve(HttpSessionProtocol.self)!)
//        }.inObjectScope(.container)
//    }

}
