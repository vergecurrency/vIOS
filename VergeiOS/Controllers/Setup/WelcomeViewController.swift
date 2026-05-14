//
//  WelcomeViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 06-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    var applicationRepository: ApplicationRepository!
    var transactionManager: TransactionManager!
    var pendingWalletProfileName: String?
    private var continuingAfterWalletNamePrompt = false
    private var redirectedToExistingWallet = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !redirectedToExistingWallet,
              pendingWalletProfileName == nil else {
            return
        }

        guard applicationRepository.selectFirstUsableWalletProfileIfNeeded() else {
            return
        }

        redirectedToExistingWallet = true
        showExistingWalletUnlock()
    }

    private func showExistingWalletUnlock() {
        let pinUnlockView = PinUnlockViewController.createFromStoryBoard()
        pinUnlockView.applicationRepository = applicationRepository
        pinUnlockView.fillPinFor = .wallet
        pinUnlockView.completion = { authenticated in
            guard authenticated else {
                self.redirectedToExistingWallet = false
                return
            }

            pinUnlockView.performSegue(withIdentifier: "showWallet", sender: pinUnlockView)
        }

        self.present(pinUnlockView, animated: false)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == "create" || identifier == "restore" else {
            return true
        }

        if continuingAfterWalletNamePrompt || pendingWalletProfileName?.isEmpty == false {
            return true
        }

        askForWalletName(segueIdentifier: identifier)
        return false
    }

    private func askForWalletName(segueIdentifier: String) {
        let walletNumber = applicationRepository.walletProfiles.count + 1
        let alert = UIAlertController(title: "Name wallet", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Wallet name"
            textField.text = "Wallet \(walletNumber)"
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.pendingWalletProfileName = name?.isEmpty == false ? name : "Wallet \(walletNumber)"
            self.continuingAfterWalletNamePrompt = true
            self.performSegue(withIdentifier: segueIdentifier, sender: self)
        })

        self.present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let navigationController = segue.destination as? UINavigationController else {
            return
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationController.modalPresentationStyle = .formSheet
        }

        self.transactionManager.removeAll()
        self.applicationRepository.beginNewWalletProfile(name: pendingWalletProfileName)
        continuingAfterWalletNamePrompt = false

        if let vc = navigationController.viewControllers.first as? SelectPinViewController {
            vc.segueIdentifier = segue.identifier
        }
    }
}
