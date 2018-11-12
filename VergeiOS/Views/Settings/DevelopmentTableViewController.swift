//
//  DevelopmentTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 17-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class DevelopmentTableViewController: UITableViewController {

    @IBOutlet weak var walletAmountTextField: UITextField!
    
    override func viewDidLoad() {
        walletAmountTextField.text = "\(ApplicationManager.default.amount)"
    }
    
    @IBAction func saveSettings(_ sender: Any) {
        if let amount = Double(walletAmountTextField.text!) {
            ApplicationManager.default.amount = NSNumber(value: amount)
        }
    }
}
