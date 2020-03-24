//
// Created by Swen van Zanten on 24/03/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

class TransactionServiceProvider: ServiceProvider {
    override func register() {
        container.storyboardInitCompleted(SelectRecipientTableViewController.self) { r, c in
            c.addressBookManager = r.resolve(AddressBookRepository.self)
        }

        container.storyboardInitCompleted(ContactsTableViewController.self) { r, c in
            c.addressBookManager = r.resolve(AddressBookRepository.self)
        }
    }
}
