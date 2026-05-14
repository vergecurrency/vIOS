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
    var applicationRepository: ApplicationRepository!
    var credentials: Credentials!
    var walletClient: WalletClientProtocol!
    var walletManager: WalletManagerProtocol!
    var walletTicker: WalletTicker!
    var fiatRateTicker: FiatRateTicker!
    var transactionManager: TransactionManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Wallets",
            style: .plain,
            target: self,
            action: #selector(showWalletProfiles)
        )
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "ElectrumX",
            style: .plain,
            target: self,
            action: #selector(showElectrumXServers)
        )
    }

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

    @objc private func showElectrumXServers() {
        guard let controller = Application.container.resolve(ElectrumXServersTableViewController.self) else {
            return
        }

        self.navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func showWalletProfiles() {
        let alert = UIAlertController(title: "Wallets", message: nil, preferredStyle: .actionSheet)
        let profiles = applicationRepository.walletProfiles
        let activeProfileId = applicationRepository.activeWalletProfileId

        for (index, profile) in profiles.enumerated() {
            let prefix = profile.id == activeProfileId ? "✓ " : ""
            let name = displayName(for: profile, at: index)
            alert.addAction(UIAlertAction(title: "\(prefix)\(name)", style: .default) { _ in
                self.switchWalletProfile(profile)
            })
        }

        alert.addAction(UIAlertAction(title: "Add Wallet", style: .default) { _ in
            DispatchQueue.main.async {
                self.askForNewWalletName()
            }
        })
        alert.addAction(UIAlertAction(title: "Rename Wallet", style: .default) { _ in
            DispatchQueue.main.async {
                self.showRenameWalletPicker()
            }
        })
        alert.addAction(UIAlertAction(title: "Wallet Details", style: .default) { _ in
            DispatchQueue.main.async {
                self.showWalletDetails()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = self.navigationItem.rightBarButtonItem
        }

        self.present(alert, animated: true)
    }

    private func showWalletDetails() {
        let profiles = applicationRepository.walletProfiles
        let activeProfileId = applicationRepository.activeWalletProfileId
        let details = profiles.enumerated().map { index, profile -> String in
            let prefix = profile.id == activeProfileId ? "* " : ""
            let material = self.applicationRepository.walletMaterialSummary(profileId: profile.id)

            return "\(prefix)\(displayName(for: profile, at: index))\n\(material)"
        }.joined(separator: "\n\n")

        let message = details.isEmpty ? "No wallet profiles are registered." : details
        let alert = UIAlertController(title: "Wallet Details", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    private func askForNewWalletName() {
        let alert = UIAlertController(title: "Name wallet", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Wallet name"
            textField.text = "Wallet \(self.applicationRepository.walletProfiles.count + 1)"
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            let name = alert.textFields?.first?.text ?? ""
            self.presentAddWalletFlow(named: name)
        })

        self.present(alert, animated: true)
    }

    private func showRenameWalletPicker() {
        let profiles = applicationRepository.walletProfiles
        guard !profiles.isEmpty else {
            let alert = UIAlertController(
                title: "Rename Wallet",
                message: "No restored wallets are available to rename.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }

        let alert = UIAlertController(title: "Rename Wallet", message: nil, preferredStyle: .actionSheet)

        for (index, profile) in profiles.enumerated() {
            alert.addAction(UIAlertAction(title: displayName(for: profile, at: index), style: .default) { _ in
                DispatchQueue.main.async {
                    self.askForWalletName(profile: profile)
                }
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = self.navigationItem.rightBarButtonItem
        }

        self.present(alert, animated: true)
    }

    private func askForWalletName(profile: WalletProfile) {
        let alert = UIAlertController(title: "Rename wallet", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Wallet name"
            textField.text = profile.name
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let name = alert.textFields?.first?.text ?? ""
            self.applicationRepository.renameWalletProfile(id: profile.id, name: name)
        })

        self.present(alert, animated: true)
    }

    private func displayName(for profile: WalletProfile, at index: Int) -> String {
        let fallbackName = "Wallet \(index + 1)"
        let name = profile.name == "ioswallet" ? fallbackName : profile.name

        guard let walletId = profile.walletId, !walletId.isEmpty else {
            return name
        }

        return "\(name) (\(String(walletId.prefix(8))))"
    }

    private func switchWalletProfile(_ profile: WalletProfile) {
        guard profile.id != applicationRepository.activeWalletProfileId else {
            return
        }

        let originalProfileId = applicationRepository.activeWalletProfileId
        let switchingToProfileId = profile.id
        walletTicker.stop()
        fiatRateTicker.stop()
        applicationRepository.switchWalletProfile(id: profile.id)

        if let mnemonic = applicationRepository.mnemonic,
           let passphrase = applicationRepository.passphrase {
            credentials.reset(mnemonic: mnemonic, passphrase: passphrase)
        } else {
            applicationRepository.switchWalletProfile(id: originalProfileId)
            walletTicker.start()
            fiatRateTicker.start()
            showWalletSwitchError("The selected wallet is missing its recovery data.")
            return
        }

        walletClient.resetServiceUrl(baseUrl: applicationRepository.walletServiceUrl)
        transactionManager.removeAll()
        applicationRepository.amount = 0
        NotificationCenter.default.post(name: .didSwitchWalletProfile, object: profile)

        walletManager.getStatus()
            .then { status in
                guard self.applicationRepository.activeWalletProfileId == switchingToProfileId else {
                    return
                }

                let openedWalletId = status.wallet?.id

                if let expectedWalletId = profile.walletId,
                   let openedWalletId = openedWalletId,
                   expectedWalletId != openedWalletId {
                    self.walletTicker.start()
                    self.fiatRateTicker.start()
                    self.showWalletSwitchError("VWS opened a different wallet than the one saved for this profile. Expected \(String(expectedWalletId.prefix(8))), got \(String(openedWalletId.prefix(8))).")
                    return
                }

                self.applicationRepository.walletId = openedWalletId

                self.walletClient.getBalance { _, info in
                    guard self.applicationRepository.activeWalletProfileId == switchingToProfileId else {
                        return
                    }

                    if let info = info {
                        self.applicationRepository.amount = info.availableAmountValue
                    } else {
                        self.applicationRepository.amount = 0
                    }

                    self.walletTicker.start()
                    self.fiatRateTicker.start()
                    NotificationCenter.default.post(name: .didChangeWalletAmount, object: nil)
                    NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)
                    self.showSwitchedWalletAlert(profile)
                }
            }
            .catch { _ in
                guard self.applicationRepository.activeWalletProfileId == switchingToProfileId else {
                    return
                }

                self.applicationRepository.amount = 0
                self.walletTicker.start()
                self.fiatRateTicker.start()
                NotificationCenter.default.post(name: .didChangeWalletAmount, object: nil)
                NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)
                self.showSwitchedWalletAlert(profile)
            }
    }

    private func showWalletSwitchError(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Wallet switch failed",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func showSwitchedWalletAlert(_ profile: WalletProfile) {
        DispatchQueue.main.async {
            guard let index = self.applicationRepository.walletProfiles.firstIndex(where: { $0.id == profile.id }) else {
                return
            }

            let alert = UIAlertController(
                title: "Wallet switched",
                message: self.displayName(for: profile, at: index),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    private func presentAddWalletFlow(named name: String) {
        walletTicker.stop()
        fiatRateTicker.stop()

        let controller = UIStoryboard.createFromStoryboard(name: "Setup", type: WelcomeViewController.self)
        controller.pendingWalletProfileName = name
        let navigationController = UINavigationController(rootViewController: controller)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissPresentedWalletFlow)
        )
        navigationController.modalPresentationStyle = .fullScreen

        self.present(navigationController, animated: true)
    }

    @objc private func dismissPresentedWalletFlow() {
        self.presentedViewController?.dismiss(animated: true) {
            if self.applicationRepository.setup {
                self.walletTicker.start()
                self.fiatRateTicker.start()
            }
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

        return number
    }
}
