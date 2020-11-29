//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class WalletViewServiceProvider: ServiceProvider {

    override func register() {
        container.storyboardInitCompleted (WalletViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (TransactionsTableViewController.self) { r, c in
            c.transactionManager = r.resolve(TransactionManager.self)
            c.addressBookManager = r.resolve(AddressBookRepository.self)
        }

        container.storyboardInitCompleted (TransactionTableViewController.self) { r, c in
            c.ratesClient = r.resolve(RatesClient.self)
            c.transactionManager = r.resolve(TransactionManager.self)
            c.addressBookManager = r.resolve(AddressBookRepository.self)
        }

        container.storyboardInitCompleted(AddressesTableViewController.self) { r, c in
            c.credentials = r.resolve(Credentials.self)
            c.walletClient = r.resolve(WalletClientProtocol.self)
            c.transactionManager = r.resolve(TransactionManager.self)
        }

        container.storyboardInitCompleted (ContactTableViewController.self) { r, c in
            c.transactionManager = r.resolve(TransactionManager.self)
            c.addressBookManager = r.resolve(AddressBookRepository.self)
        }
    }

}
