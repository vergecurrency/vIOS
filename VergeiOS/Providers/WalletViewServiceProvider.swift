//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class WalletViewServiceProvider: ServiceProvider {

    override func register() {
        container.storyboardInitCompleted (WalletViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.fiatRateTicker = r.resolve(FiatRateTicker.self)
        }
    }

}
