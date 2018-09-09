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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTransaction(_ transaction: Transaction) {
        textLabel?.text = transaction.address
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        detailTextLabel?.text = df.string(from: transaction.time)
        
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
