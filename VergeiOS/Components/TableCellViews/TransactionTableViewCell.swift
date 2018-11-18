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

    func setTransaction(_ transaction: TxHistory, address: Contact?) {
        setAccount(transaction, address: address)
        setDateTime(transaction)
        setAmount(transaction)
    }

    func setTransaction(_ transaction: TxHistory) {
        textLabel?.text = transaction.txid
        textLabel?.textColor = UIColor.secondaryLight().withAlphaComponent(0.75)
        setDateTime(transaction)
        setAmount(transaction)
    }
    
    fileprivate func setAccount(_ transaction: TxHistory, address: Contact?) {
        textLabel?.text = transaction.address.truncated(limit: 6, position: .tail, leader: "******")

        if transaction.category == .Moved {
            textLabel?.text = "Moved"
        }

        if address != nil {
            textLabel?.text = address?.name
            textLabel?.textColor = UIColor.secondaryDark()
        } else {
            textLabel?.textColor = UIColor.secondaryLight().withAlphaComponent(0.75)
        }
    }
    
    fileprivate func setDateTime(_ transaction: TxHistory) {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        detailTextLabel?.text = df.string(from: transaction.timeReceived)
    }
    
    fileprivate func setAmount(_ transaction: TxHistory) {
        var prefix = ""
        if transaction.category == .Sent {
            amountLabel.textColor = UIColor.vergeRed()
            imageView?.tintColor = transaction.confirmations < 1 ? UIColor.vergeGrey() : UIColor.vergeRed()
            imageView?.image = UIImage(named: transaction.confirmations < 1 ? "Sending" : "Sent")

            prefix = "-"
        } else if transaction.category == .Moved {
            amountLabel.textColor = UIColor.vergeGrey()
            imageView?.tintColor = UIColor.vergeGrey()
            imageView?.image = UIImage(named: "Moved")

            prefix = ""
        } else {
            amountLabel.textColor = UIColor.vergeGreen()
            imageView?.tintColor = UIColor.vergeGreen()
            
            prefix = "+"
        }
        
        amountLabel.text = "\(prefix) \(transaction.amountValue.toCurrency(currency: "XVG", fractDigits: 2))"
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
