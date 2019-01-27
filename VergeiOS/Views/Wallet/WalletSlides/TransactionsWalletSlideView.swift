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
    
    let addressBookManager = AddressBookRepository()
    var items: [TxHistory] = []
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(TransactionsWalletSlideView.handleRefresh(_:)),
            for: UIControl.Event.valueChanged
        )
        refreshControl.tintColor = UIColor.primaryLight()
        
        return refreshControl
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getTransactions(notification:)),
            name: .didBroadcastTx,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getTransactions(notification:)),
            name: .didReceiveTransaction,
            object: nil
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        installTableViewPlaceholder()
        getTransactions()

        tableView.layer.cornerRadius = 5.0
        tableView.clipsToBounds = true
        tableView.addSubview(refreshControl)
    }
    
    func installTableViewPlaceholder() {
        let nib = UINib(nibName: "NoWalletTransactionsPlaceholderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NoWalletTransactionsPlaceholderTableViewCell")
        tableView?.placeholdersProvider = PlaceholdersProvider(placeholders:
            Placeholder(cellIdentifier: "NoWalletTransactionsPlaceholderTableViewCell", key: PlaceholderKey.noResultsKey)
        )
    }
    
    @objc func getTransactions(notification: Notification? = nil) {
        TransactionManager.shared.all { transactions in
            self.items = transactions

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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

        var recipient: Contact? = nil
        if let name = addressBookManager.name(byAddress: item.address) {
            recipient = Contact()
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

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        TransactionManager.shared.sync(limit: 10) { transactions in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)

            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
}
