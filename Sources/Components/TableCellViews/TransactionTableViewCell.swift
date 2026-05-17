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

    let amountLabel: UILabel = UILabel()

    override func setup() {}

    override func update() {}

    override func awakeFromNib() {
        super.awakeFromNib()

        amountLabel.font = UIFont.avenir(size: 15).demiBold()
        accessoryView = amountLabel
        backgroundColor = ThemeManager.shared.backgroundWhite()
        contentView.backgroundColor = .clear
        textLabel?.font = UIFont.avenir(size: 16).demiBold()
        detailTextLabel?.font = UIFont.avenir(size: 12).medium()
        detailTextLabel?.numberOfLines = 2
        imageView?.contentMode = .scaleAspectFit
    }

    func setTransaction(_ transaction: Vws.TxHistory, address: Contact?) {
        setAccount(transaction, address: address)
        setDateTime(transaction)
        setAmount(transaction)
    }

    func setTransaction(_ transaction: Vws.TxHistory) {
        setAccount(transaction, address: nil)
        setDateTime(transaction)
        setAmount(transaction)
    }

    fileprivate func setAccount(_ transaction: Vws.TxHistory, address: Contact?) {
        let resolvedName = transaction.resolvedRecipientName
        textLabel?.text = transaction.displayRecipient.truncated(limit: 26, position: .middle, leader: "...")

        if let resolvedName = resolvedName {
            textLabel?.text = resolvedName
            textLabel?.textColor = ThemeManager.shared.primaryLight()
        } else if transaction.memo != nil {
            textLabel?.text = transaction.memo!
            textLabel?.textColor = ThemeManager.shared.primaryDark()
        } else if address != nil {
            textLabel?.text = address?.name
            textLabel?.textColor = ThemeManager.shared.secondaryDark()
        } else {
            textLabel?.textColor = ThemeManager.shared.secondaryLight().withAlphaComponent(0.75)
        }

        if transaction.category == .Moved {
            textLabel?.text = "transaction.state.moved".localized
        }

        if transaction.category == .Received {
            textLabel?.text = transaction.confirmed ?
                "transaction.state.received".localized :
                "transaction.state.pending".localized
        }
    }

    fileprivate func setDateTime(_ transaction: Vws.TxHistory) {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        let date = df.string(from: transaction.timeReceived)
        if let _ = transaction.resolvedRecipientName {
            detailTextLabel?.text = "\(date)\n\(transaction.address.truncated(limit: 28, position: .middle, leader: "..."))"
        } else {
            detailTextLabel?.text = date
        }
        detailTextLabel?.textColor = ThemeManager.shared.secondaryLight()
    }

    fileprivate func setAmount(_ transaction: Vws.TxHistory) {
        var prefix = ""
        if transaction.category == .Sent {
            amountLabel.textColor = ThemeManager.shared.vergeRed()
            imageView?.tintColor = transaction.confirmed ?
                ThemeManager.shared.vergeRed() :
                ThemeManager.shared.vergeGrey()
            imageView?.image = UIImage(named: transaction.confirmed ?  "Sent" : "Sending")

            prefix = "-"
        } else if transaction.category == .Moved {
            amountLabel.textColor = ThemeManager.shared.vergeGrey()
            imageView?.tintColor = ThemeManager.shared.vergeGrey()
            imageView?.image = UIImage(named: "Moved")

            prefix = ""
        } else {
            amountLabel.textColor = ThemeManager.shared.vergeGreen()
            imageView?.tintColor = transaction.confirmed ?
                ThemeManager.shared.vergeGreen() :
                ThemeManager.shared.vergeGrey()
            imageView?.image = UIImage(named: transaction.confirmed ? "Received" : "Receiving")

            prefix = "+"
        }

        amountLabel.text = "\(prefix) \(transaction.amountValue.toXvgCurrency())"
        amountLabel.sizeToFit()
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
