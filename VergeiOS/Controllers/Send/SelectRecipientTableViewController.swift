//
//  SelectRecipientTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SelectRecipientTableViewController: AbstractContactsTableViewController {
    
    weak var sendTransactionDelegate: SendTransactionDelegate!
    var sendTransaction: TransactionFactory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendTransaction = sendTransactionDelegate.getSendTransaction()

        loadContacts()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        let address = contact(byIndexpath: indexPath)

        if address.address == sendTransaction?.address {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendTransaction?.address = contact(byIndexpath: indexPath).address
        sendTransactionDelegate.didChangeSendTransaction(sendTransaction!)

        searchController.isActive = false
        closeViewController(self)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    @IBAction func closeViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
