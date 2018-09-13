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

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var currencyLabel: UILabel!

    let localAuthIndexPath = IndexPath(row: 2, section: 1)

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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addShadowedEdges(scrollView: scrollView)
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
}

extension UITableViewController {
    
    
    func addShadowedEdges(scrollView: UIScrollView) {
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
        if scrollView.contentOffset.y > 20 {
            addShadow(navBar)
        } else {
            deleteShadow(navBar)
        }
    }
    
    func addShadow(_ view: UIView) {
        if view.layer.shadowRadius == 10.0 {
            return
        }
        
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        view.layer.masksToBounds = false
        view.layer.shadowRadius = 10.0
        
        let fadeAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 0.2
        fadeAnimation.duration = 0.2
        
        view.layer.add(fadeAnimation, forKey: "FadeAnimation")
        view.layer.shadowOpacity = 0.2
    }
    
    func deleteShadow(_ view: UIView) {
        if view.layer.shadowRadius == 0.0 {
            return
        }
        
        view.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        view.layer.shadowRadius = 0
        
        let fadeAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        fadeAnimation.fromValue = 0.2
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.2
        
        view.layer.add(fadeAnimation, forKey: "FadeAnimation")
        view.layer.shadowOpacity = 0.0
    }
    
}
