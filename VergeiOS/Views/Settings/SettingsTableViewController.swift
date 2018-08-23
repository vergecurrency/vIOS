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

        currencyLabel.text = WalletManager.default.currency
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //handle sections
        switch indexPath.section {
        case 2: otherHandler(index: indexPath.row)
        default: break
        }
    }

    private func otherHandler(index: Int) -> Void {
        
        switch index {
        case 0:
            loadVC(identifer: "creditsVC", title: "Credits")
        case 2:
            SKStoreReviewController.requestReview()
        case 3:
            loadWebsite(url: "https://vergecurrency.com/")
        case 4:
            loadWebsite(url: "https://github.com/vergecurrency/vIOS")
        default: break
        }

        tableView.deselectRow(at: IndexPath(row: index, section: 2), animated: true)
    }
    
    private func loadWebsite(url: String) -> Void {
        if let path: URL = URL(string: url) {
            UIApplication.shared.open(path, options: [:])
        }
    }
    
    private func loadVC(identifer: String, title: String) -> Void {
        let creditsVC: UIViewController = (storyboard?.instantiateViewController(withIdentifier: "creditsVC"))! 
            creditsVC.title = title
            navigationController?.pushViewController(creditsVC, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocalAuthTableViewController" {
            let pinUnlockView = PinUnlockViewController.createFromStoryBoard()
            pinUnlockView.cancelable = true
            present(pinUnlockView, animated: true)
        }

        if segue.identifier == "SelectPinViewController" {
            let pinUnlockView = PinUnlockViewController.createFromStoryBoard()
            pinUnlockView.cancelable = true
            present(pinUnlockView, animated: true)

            if let vc = segue.destination as? SelectPinViewController {
                vc.navigationItem.leftBarButtonItem = nil
                vc.completion = { pin in
                    vc.navigationController?.popToViewController(self, animated: true)
                }
            }
        }
    }
}
