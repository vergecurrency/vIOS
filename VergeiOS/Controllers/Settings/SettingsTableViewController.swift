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

    let localAuthIndexPath = IndexPath(row: 2, section: 1)
    var applicationRepository: ApplicationRepository!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        currencyLabel.text = applicationRepository.currency
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
        case 2:
            SKStoreReviewController.requestReview()
        case 3:
            loadWebsite(url: Constants.website)
        case 4:
            loadWebsite(url: Constants.iOSRepo)
        default: break
        }

        tableView.deselectRow(at: IndexPath(row: index, section: 2), animated: true)
    }
    
    private func loadWebsite(url: String) -> Void {
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
            cell.textLabel?.text = "Use Touch ID"
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

    @IBAction func themeSwitched(_ sender: UISwitch) {
//        var theme: ThemeColorsProtocol
//        if (sender.isOn) {
//            theme = LightThemeColors()
//            UserDefaults.standard.set("light", forKey: "ThemeColors")
//        } else {
//            theme = DarkThemeColors()
//            UserDefaults.standard.set("dark", forKey: "ThemeColors")
//        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        ThemeManager.shared.useDarkTheme = sender.isOn
        ThemeManager.shared.initialize(withWindow: appDelegate.window!)

        NotificationCenter.default.post(name: .themeChanged, object: nil)

        let windows = UIApplication.shared.windows as [UIWindow]
        for window in windows {
            let subviews = window.subviews as [UIView]
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
}
