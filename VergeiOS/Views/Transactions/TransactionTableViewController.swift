//
//  TransactionTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TransactionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: PlaceholderTableView!
    
    let addressBookManager = AddressBookManager()
    var items: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let transactions = WalletManager.default.getTransactions(offset: 0, limit: 7).sorted { a, b in
            return a.blockindex > b.blockindex
        }
        
        items = transactions
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Transaction Details"
        }
        
        return "Transaction History"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.secondaryDark()
        header.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        header.textLabel?.frame = header.frame
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionDetailCell")!
            
            switch indexPath.row {
            case 0:
                cell.imageView?.image = UIImage(named: "Address")
                cell.textLabel?.text = "From Address"
                cell.detailTextLabel?.text = items.first?.address
                break
            case 1:
                cell.imageView?.image = UIImage(named: "Confirmations")
                cell.textLabel?.text = "Confirmations"
                cell.detailTextLabel?.text = "\(items.first?.confirmations ?? 0)"
                break
            case 2:
                cell.imageView?.image = UIImage(named: "Block")
                cell.textLabel?.text = "Blockhash"
                cell.detailTextLabel?.text = items.first?.blockhash
                break
            default:
                break
            }
            
            cell.imageView?.tintColor = UIColor.secondaryLight()
            
            return cell
        }
        
        
        let cell = Bundle.main.loadNibNamed("TransactionTableViewCell", owner: self, options: nil)?.first as! TransactionTableViewCell
        
        let item = items[indexPath.row]
        
        let recipient = Address()
        recipient.address = item.address
        recipient.name = "CryptoRekt"
        
        cell.setTransaction(item, address: recipient)
        
        return cell
    }
    
    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
