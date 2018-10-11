//
//  TransactionsWalletSlideView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import HGPlaceholders

class TransactionsWalletSlideView: WalletSlideView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: TableView!
    
    let addressBookManager = AddressBookManager()
    var items: [Transaction] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        installTableViewPlaceholder()
        getTransactions()

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.layer.cornerRadius = 5.0
        tableView.clipsToBounds = true
    }
    
    func installTableViewPlaceholder() {
        let nib = UINib(nibName: "NoWalletTransactionsPlaceholderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NoWalletTransactionsPlaceholderTableViewCell")
        tableView?.placeholdersProvider = PlaceholdersProvider(placeholders:
            Placeholder(cellIdentifier: "NoWalletTransactionsPlaceholderTableViewCell", key: PlaceholderKey.noResultsKey)
        )
    }
    
    func getTransactions() {
        items = WalletManager.default.getTransactions(offset: 0, limit: 20).sorted { a, b in
            return a.blockindex > b.blockindex
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.tableFooterView?.isHidden = items.count < 7
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TransactionTableViewCell", owner: self, options: nil)?.first as! TransactionTableViewCell
        
        let item = items[indexPath.row]

        var recipient: Address? = nil
        if let name = addressBookManager.name(byAddress: item.address) {
            recipient = Address()
            recipient?.address = item.address
            recipient?.name = name
        }
        
        cell.setTransaction(item, address: recipient)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentContainerViewController()?.performSegue(withIdentifier: "TransactionTableViewController", sender: items[indexPath.row])
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
