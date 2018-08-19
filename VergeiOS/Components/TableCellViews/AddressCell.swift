//
//  AddressCell.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBAction func pasteButtonClicked(_ sender: Any) {
        addressTextField.text = UIPasteboard.general.string
    }
    
    @IBAction func bansInfoButtonClicked(_ sender: Any) {
        if let url = URL(string: "https://github.com/hellc/bans") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
