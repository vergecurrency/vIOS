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
        textLabel?.textColor = ThemeManager.shared.secondaryLight().withAlphaComponent(0.75)
        setDateTime(transaction)
        setAmount(transaction)
    }
    
    fileprivate func setAccount(_ transaction: TxHistory, address: Contact?) {
        textLabel?.text = transaction.address.truncated(limit: 12, position: .tail, leader: "******")

        if transaction.memo != nil {
            textLabel?.text = transaction.memo!
            textLabel?.textColor = ThemeManager.shared.primaryDark()
        } else if address != nil {
            textLabel?.text = address?.name
            textLabel?.textColor = ThemeManager.shared.secondaryDark()
        } else {
            textLabel?.textColor = ThemeManager.shared.secondaryLight().withAlphaComponent(0.75)
        }
        
        if transaction.category == .Moved {
            textLabel?.text = "Moved"
        }
        
        if transaction.category == .Received {
            textLabel?.text = transaction.confirmed ? "Received" : "Pending"
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
            amountLabel.textColor = ThemeManager.shared.vergeRed()
            imageView?.tintColor = transaction.confirmed ? ThemeManager.shared.vergeRed() : ThemeManager.shared.vergeGrey()
            imageView?.image = UIImage(named: transaction.confirmed ?  "Sent" : "Sending")

            prefix = "-"
        } else if transaction.category == .Moved {
            amountLabel.textColor = ThemeManager.shared.vergeGrey()
            imageView?.tintColor = ThemeManager.shared.vergeGrey()
            imageView?.image = UIImage(named: "Moved")

            prefix = ""
        } else {
            amountLabel.textColor = ThemeManager.shared.vergeGreen()
            imageView?.tintColor = transaction.confirmed ? ThemeManager.shared.vergeGreen() : ThemeManager.shared.vergeGrey()
            imageView?.image = UIImage(named: transaction.confirmed ? "Received" : "Receiving")
            
            prefix = "+"
        }
        
        amountLabel.text = "\(prefix) \(transaction.amountValue.toXvgCurrency())"
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
