//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class ReceiveViewServiceProvider: ServiceProvider {

    override func register() {
        container.storyboardInitCompleted (ReceiveViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.walletClient = r.resolve(WalletClient.self)
            c.transactionManager = r.resolve(TransactionManager.self)
            c.fiatRateTicker = r.resolve(FiatRateTicker.self)
        }
    }

}
