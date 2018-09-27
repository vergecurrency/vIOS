//
//  SelectRecipientTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SelectRecipientTableViewController: EdgedTableViewController, UITextFieldDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var sendTransactionDelegate: SendTransactionDelegate!

    var addresses: [Address] = []
    var sendTransaction: SendTransaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendTransaction = sendTransactionDelegate.getSendTransaction()
        
        addresses = AddressBookManager().all()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.addresses.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "A"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressBookCell", for: indexPath)

        cell.textLabel?.text = addresses[indexPath.row].name
        cell.detailTextLabel?.text = addresses[indexPath.row].address
        
        if addresses[indexPath.row].address == sendTransaction?.address {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendTransaction?.address = addresses[indexPath.row].address
        
        sendTransactionDelegate.didChangeSendTransaction(sendTransaction!)
        
        self.closeViewController(self)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }

    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SelectRecipientTableViewController: UISearchBarDelegate {
    
}
