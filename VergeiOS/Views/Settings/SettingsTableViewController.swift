//
//  SettingsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import StoreKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var currencyLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.statusBarStyle = .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //handle sections
        switch indexPath.section {
        case 2: otherHandler(index: indexPath.row)
        default: break
        }
        
        currencyLabel.text = WalletManager.default.currency
    }
    
    private func otherHandler(index: Int) -> Void {
        switch index {
        case 2:
            SKStoreReviewController.requestReview()
        case 3:
            loadWebsite(url: "https://vergecurrency.com/")
        case 4:
            loadWebsite(url: "https://github.com/vergecurrency/vIOS")
        default: break
        }
    }
    
    private func loadWebsite(url: String) -> Void {
        if let path: URL = URL(string: url) {
            UIApplication.shared.open(path, options: [:])
        }
    }
}
