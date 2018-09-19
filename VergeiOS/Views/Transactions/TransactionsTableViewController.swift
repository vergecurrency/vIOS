//
//  TransactionsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import HGPlaceholders

class TransactionsTableViewController: EdgedTableViewController {
    
    let addressBookManager = AddressBookManager()
    var placeholderTableView: TableView?
    var items: [Date: [Transaction]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installTableViewPlaceholder()
        getTransactions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func installTableViewPlaceholder() {
        let nib = UINib(nibName: "NoTransactionsPlaceholderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NoTransactionsPlaceholderTableViewCell")
        
        let placeholdersProvider = PlaceholdersProvider(placeholders:
            Placeholder(cellIdentifier: "NoTransactionsPlaceholderTableViewCell", key: PlaceholderKey.noResultsKey)
        )
        
        placeholderTableView = tableView as? TableView
        placeholderTableView?.placeholdersProvider = placeholdersProvider
    }
    
    func getTransactions() {
        let transactions = WalletManager.default.getTransactions(offset: 0, limit: 7).sorted { a, b in
            return a.blockindex > b.blockindex
        }
        
        let cal = Calendar.current
        items = Dictionary(grouping: transactions, by: { cal.startOfDay(for: $0.time) })
    }
    
    func sectionDate(bySection section: Int) -> Date {
        let dates = Array(items.keys)
        
        return dates[section]
    }
    
    func transactions(bySection section: Int) -> [Transaction] {
        let date = sectionDate(bySection: section)
        
        return items[date] ?? []
    }
    
    func transaction(byIndexpath indexPath: IndexPath) -> Transaction {
        let items = transactions(bySection: indexPath.section)
        
        return items[indexPath.row]
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions(bySection: section).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TransactionTableViewCell", owner: self, options: nil)?.first as! TransactionTableViewCell
        
        let item = transaction(byIndexpath: indexPath)

        var recipient: Address? = nil
        if let name = addressBookManager.name(byAddress: item.address) {
            recipient = Address()
            recipient?.address = item.address
            recipient?.name = name
        }

        cell.setTransaction(item, address: recipient)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TransactionTableViewController", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        
        return df.string(from: sectionDate(bySection: section))
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TransactionTableViewController" {
            if let vc = segue.destination as? TransactionTableViewController {
                vc.navigationItem.leftBarButtonItem = nil
                vc.transaction = transaction(byIndexpath: tableView.indexPathForSelectedRow!)
            }
        }
    }

}
