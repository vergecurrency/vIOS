//
//  TransactionTableViewCell.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 04-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Eureka

class TransactionTableViewCell: Cell<String>, CellType {

    @IBOutlet weak var amountLabel: UILabel!

    override func setup() {}

    override func update() {}

    func setTransaction(_ transaction: Transaction, address: Address?) {
        setAccount(transaction, address: address)
        setDateTime(transaction)
        setAmount(transaction)
    }

    func setTransaction(_ transaction: Transaction) {
        textLabel?.text = transaction.blockhash
        textLabel?.textColor = UIColor.secondaryLight().withAlphaComponent(0.75)
        setDateTime(transaction)
        setAmount(transaction)
    }
    
    fileprivate func setAccount(_ transaction: Transaction, address: Address?) {
        textLabel?.text = transaction.address.truncated(limit: 6, position: .tail, leader: "******")
        
        if address != nil {
            textLabel?.text = address?.name
            textLabel?.textColor = UIColor.secondaryDark()
        } else {
            textLabel?.textColor = UIColor.secondaryLight().withAlphaComponent(0.75)
        }
    }
    
    fileprivate func setDateTime(_ transaction: Transaction) {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        detailTextLabel?.text = df.string(from: transaction.time)
    }
    
    fileprivate func setAmount(_ transaction: Transaction) {
        var prefix = ""
        if transaction.category == .Sent {
            amountLabel.textColor = UIColor.vergeRed()
            imageView?.tintColor = UIColor.vergeRed()
            imageView?.image = UIImage(named: "Sent")
            
            prefix = "-"
        } else {
            amountLabel.textColor = UIColor.vergeGreen()
            imageView?.tintColor = UIColor.vergeGreen()
            
            prefix = "+"
        }
        
        amountLabel.text = "\(prefix) \(transaction.amount.toCurrency(currency: "XVG", fractDigits: 2))"
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class TransactionRow: Row<TransactionTableViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<TransactionTableViewCell>(nibName: "TransactionTableViewCell")
    }
}
