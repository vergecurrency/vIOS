//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class HttpServiceProvider: ServiceProvider {

    override func boot() {
        // Start the tor client
        container.resolve(TorClient.self)?.start {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.torClientStarted()
            }
        }
    }

    override func register() {
        container.register(TorClient.self) { r in
            return TorClient(applicationRepository: r.resolve(ApplicationRepository.self)!)
        }.inObjectScope(.container)

        container.register(RatesClient.self) { r in
            return RatesClient(torClient: r.resolve(TorClient.self)!)
        }.inObjectScope(.container)
    }

    private func torClientStarted() {
        // Start the price ticker.
        container.resolve(FiatRateTicker.self)?.start()

        let appRepo = container.resolve(ApplicationRepository.self)
        if !appRepo!.setup {
            return
        }

        // Start the wallet ticker.
        container.resolve(WalletTicker.self)?.start()

        if #available(iOS 12.0, *) {
            IntentsManager.donateIntents()
        }
    }

}
