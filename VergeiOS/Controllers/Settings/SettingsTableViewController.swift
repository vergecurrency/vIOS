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

    let localAuthIndexPath = IndexPath(row: 3, section: 2)
    let bgReadingIndexPath = IndexPath(row: 4, section: 2)
    var applicationRepository: ApplicationRepository!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.currencyLabel.text = self.applicationRepository.currency

        if let indexPath = self.tableView.indexPathForSelectedRow,
            let row = self.tableView.cellForRow(at: indexPath) {
            if row.accessoryType == .none {
                self.tableView.deselectRow(at: indexPath, animated: animated)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //handle sections
        switch indexPath.section {
        case 3:
            self.otherHandler(index: indexPath.row)
        default: break
        }
    }

    private func otherHandler(index: Int) {
        switch index {
        case 2:
            SKStoreReviewController.requestReview()
        case 3:
            self.loadWebsite(url: Constants.website)
        case 4:
            self.loadWebsite(url: Constants.iOSRepo)
        default: return
        }

        self.tableView.deselectRow(at: IndexPath(row: index, section: 3), animated: true)
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

            self.present(pinUnlockView, animated: true)
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

            self.present(pinUnlockView, animated: true)

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

        if indexPath == self.localAuthIndexPath && LAContext.available(type: .touchID) {
            cell.textLabel?.text = "settings.localAuth.useTouchId".localized
            cell.imageView?.image = UIImage(named: "TouchID")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = super.tableView(tableView, numberOfRowsInSection: section)

        if section == self.localAuthIndexPath.section && !LAContext.anyAvailable() {
            number -= 1
        }

        if section == self.bgReadingIndexPath.section && !self.bgReadingSupported {
            number -= 1
        }

        return number
    }

    var bgReadingSupported: Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        guard let deviceModel = (withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in String.init(validatingUTF8: ptr) }
        }) else {
            return false
        }

        return deviceModel.contains("iPhone") && Float(
            deviceModel.replacingOccurrences(of: "iPhone", with: "").replacingOccurrences(of: ",", with: ".")
        ) ?? 0 >= 11
    }
}
