//
//  TransactionTableViewCell.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 04-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    
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
        if transaction.category == .Send {
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
