//
//  SettingsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import StoreKit
import LocalAuthentication

class SettingsTableViewController: EdgedTableViewController {

    @IBOutlet weak var currencyLabel: UILabel!

    let localAuthIndexPath = IndexPath(row: 4, section: 2)
    var applicationRepository: ApplicationRepository!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.currencyLabel.text = self.applicationRepository.currency
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //handle sections
        switch indexPath.section {
        case 3: otherHandler(index: indexPath.row)
        default: break
        }
    }

    private func otherHandler(index: Int) {
        switch index {
        case 1:
            SKStoreReviewController.requestReview()
        case 2:
            loadWebsite(url: Constants.website)
        case 3:
            loadWebsite(url: Constants.iOSRepo)
        default: break
        }

        tableView.deselectRow(at: IndexPath(row: index, section: 3), animated: true)
    }

    private func loadWebsite(url: String) {
        if let path: URL = URL(string: url) {
            UIApplication.shared.open(path, options: [:])
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocalAuthTableViewController" {
            let pinUnlockView = PinUnlockViewController.createFromStoryBoard()
            pinUnlockView.cancelable = true
            pinUnlockView.completion = { authenticated in
                if !authenticated {
                    self.navigationController?.popViewController(animated: false)
                }

                pinUnlockView.dismiss(animated: true)
            }

            present(pinUnlockView, animated: true)
        }

        if segue.identifier == "SelectPinViewController" {
            let pinUnlockView = PinUnlockViewController.createFromStoryBoard()
            pinUnlockView.cancelable = true
            pinUnlockView.completion = { authenticated in
                if !authenticated {
                    self.navigationController?.popViewController(animated: false)
                }

                pinUnlockView.dismiss(animated: true)
            }
            present(pinUnlockView, animated: true)

            if let vc = segue.destination as? SelectPinViewController {
                vc.navigationItem.leftBarButtonItem = nil
                vc.completion = { pin in
                    vc.navigationController?.popToViewController(self, animated: true)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if indexPath == localAuthIndexPath && LAContext.available(type: .touchID) {
            cell.textLabel?.text = "settings.localAuth.useTouchId".localized
            cell.imageView?.image = UIImage(named: "TouchID")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = super.tableView(tableView, numberOfRowsInSection: section)

        if section == localAuthIndexPath.section && !LAContext.anyAvailable() {
            return number - 1
        }

        return number
    }
}
