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

        if indexPath == self.localAuthIndexPath && !LAContext.anyAvailable() {
            cell.isHidden = true
        }

        if indexPath == self.bgReadingIndexPath && !isSupportedIphone {
            cell.isHidden = true
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0

        if indexPath == self.localAuthIndexPath && !LAContext.anyAvailable() {
            rowHeight = 0.0

        } else if indexPath == self.bgReadingIndexPath && !isSupportedIphone {
            rowHeight = 0.0

        } else {
            rowHeight = 44.0
        }

        return rowHeight
    }

    var isSupportedIphone: Bool {
        var supportedVersion = false

        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in String.init(validatingUTF8: ptr) }
        }

        let deviceModel = String.init(validatingUTF8: modelCode!)!

        switch deviceModel {

        case let decodedModelCode where decodedModelCode.contains("iPhone11"),
             let decodedModelCode where decodedModelCode.contains("iPhone12"),
             let decodedModelCode where decodedModelCode.contains("iPhone13"),
             let decodedModelCode where decodedModelCode.contains("iPhone14"),
             let decodedModelCode where decodedModelCode.contains("iPhone15"),
             let decodedModelCode where decodedModelCode.contains("iPhone16"),
             let decodedModelCode where decodedModelCode.contains("iPhone17"),
             let decodedModelCode where decodedModelCode.contains("iPhone18")
             //, let decodedModelCode where decodedModelCode.contains("x86_64") // Simulator
        :
            supportedVersion = true
        default:
            () // Ignore
        }

        return supportedVersion
    }
}
