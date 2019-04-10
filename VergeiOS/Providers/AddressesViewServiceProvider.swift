//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class AddressesViewServiceProvider: ServiceProvider {

    override func register() {
        container.storyboardInitCompleted(AddressesTableViewController.self) { r, c in
            c.credentials = r.resolve(Credentials.self)
            c.walletClient = r.resolve(WalletClient.self)
        }
    }

}
