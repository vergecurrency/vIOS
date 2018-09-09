//
//  TransactionsWalletSlideView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import InsightClient

class TransactionsWalletSlideView: WalletSlideView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allTransactionsLabel: UILabel!
    @IBOutlet weak var placeholder: UIStackView!
    
    var items: [Transaction] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()

        items = WalletManager.default.getTransactions(offset: 0, limit: 7)
        
        if items.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.placeholder.isHidden = true
                self.allTransactionsLabel.isHidden = false
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }

        // Remove the last line.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TransactionTableViewCell", owner: self, options: nil)?.first as! TransactionTableViewCell
        
        let item = items[indexPath.row]

        cell.setTransaction(item)
        
        return cell
    }
    
}
