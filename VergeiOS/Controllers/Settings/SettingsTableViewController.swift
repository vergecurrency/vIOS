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

    let localAuthIndexPath = IndexPath(row: 3, section: 3)
    var applicationRepository: ApplicationRepository!
    var credentials: Credentials!
    var walletClient: WalletClientProtocol!
    var walletManager: WalletManagerProtocol!
    var walletTicker: WalletTicker!
    var fiatRateTicker: FiatRateTicker!
    var transactionManager: TransactionManager!
    private weak var walletProfilesButton: UIButton?
    private let walletSwitchPopupTag = 83014

    override func viewDidLoad() {
        super.viewDidLoad()

        let walletButton = makeWalletProfilesButton()
        self.walletProfilesButton = walletButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: walletButton)
        self.navigationItem.leftBarButtonItem = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let walletProfilesButton = walletProfilesButton {
            applyWalletProfilesButtonStyle(to: walletProfilesButton)
        }
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
        case 1:
            if indexPath.row == 0 {
                self.showElectrumXServers()
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        case 4:
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

        self.tableView.deselectRow(at: IndexPath(row: index, section: 4), animated: true)
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

    private func makeWalletProfilesButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        button.accessibilityLabel = "Wallets"
        button.addTarget(self, action: #selector(showWalletProfiles), for: .touchUpInside)

        let label = UILabel()
        label.text = "Wallets"
        label.textColor = .white
        label.font = UIFont.avenir(size: 12).demiBold()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        button.addSubview(label)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 68),
            button.heightAnchor.constraint(equalToConstant: 34),
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
        ])
        applyWalletProfilesButtonStyle(to: button)

        return button
    }

    private func applyWalletProfilesButtonStyle(to button: UIButton) {
        let gradientName = "RetrowaveWalletProfilesButtonGradient"
        button.backgroundColor = UIColor(rgb: 0x12071A)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.75).cgColor
        button.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        button.layer.shadowOpacity = 0.38
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = .zero
        button.clipsToBounds = false

        guard button.bounds.width > 0 && button.bounds.height > 0 else {
            return
        }

        let gradient: CAGradientLayer
        if let existingGradient = button.layer.sublayers?
            .first(where: { $0.name == gradientName }) as? CAGradientLayer {
            gradient = existingGradient
        } else {
            gradient = CAGradientLayer()
            gradient.name = gradientName
            button.layer.insertSublayer(gradient, at: 0)
        }

        gradient.frame = button.bounds
        gradient.cornerRadius = button.layer.cornerRadius
        gradient.colors = [
            UIColor(rgb: 0x14071F).cgColor,
            UIColor(rgb: 0x3A125C).cgColor,
            UIColor(rgb: 0x12071A).cgColor
        ]
        gradient.locations = [0.0, 0.52, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        button.subviews.forEach { button.bringSubviewToFront($0) }
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
            self.styleWalletNameTextField(textField)
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
            self.styleWalletNameTextField(textField)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let name = alert.textFields?.first?.text ?? ""
            self.applicationRepository.renameWalletProfile(id: profile.id, name: name)
        })

        self.present(alert, animated: true)
    }

    private func styleWalletNameTextField(_ textField: UITextField) {
        textField.textColor = .white
        textField.tintColor = ThemeManager.shared.primaryLight()
        textField.backgroundColor = UIColor(rgb: 0x12061F).withAlphaComponent(0.94)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.48).cgColor
        textField.attributedPlaceholder = NSAttributedString(
            string: textField.placeholder ?? "",
            attributes: [.foregroundColor: ThemeManager.shared.secondaryLight().withAlphaComponent(0.72)]
        )
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

        guard let mnemonic = applicationRepository.mnemonic else {
            applicationRepository.switchWalletProfile(id: originalProfileId)
            walletTicker.start()
            fiatRateTicker.start()
            showWalletSwitchError("The selected wallet is missing its recovery data.")
            return
        }

        let passphrase: String
        if applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic) {
            guard let storedPassphrase = applicationRepository.passphrase else {
                applicationRepository.switchWalletProfile(id: originalProfileId)
                walletTicker.start()
                fiatRateTicker.start()
                showWalletSwitchError("The selected wallet is missing its recovery data.")
                return
            }

            passphrase = storedPassphrase
        } else {
            passphrase = ""
        }

        credentials.reset(mnemonic: mnemonic, passphrase: passphrase)

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

            self.presentWalletSwitchPopup(message: self.displayName(for: profile, at: index))
        }
    }

    private func presentWalletSwitchPopup(message: String) {
        guard let hostView = navigationController?.view ?? view else {
            return
        }

        hostView.viewWithTag(walletSwitchPopupTag)?.removeFromSuperview()

        let overlay = UIControl()
        overlay.tag = walletSwitchPopupTag
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.36)
        overlay.alpha = 0
        overlay.addTarget(self, action: #selector(dismissWalletSwitchPopup), for: .touchUpInside)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(rgb: 0x12061F)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.62).cgColor
        card.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        card.layer.shadowOpacity = 0.42
        card.layer.shadowRadius = 24
        card.layer.shadowOffset = CGSize(width: 0, height: 0)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Wallet switched"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.avenir(size: 19)
        titleLabel.numberOfLines = 1

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.textColor = ThemeManager.shared.secondaryLight()
        messageLabel.font = UIFont.avenir(size: 14)
        messageLabel.numberOfLines = 3
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.78

        let okButton = UIControl()
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.backgroundColor = UIColor(rgb: 0x1A0829)
        okButton.layer.cornerRadius = 14
        okButton.layer.borderWidth = 1
        okButton.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.72).cgColor
        okButton.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        okButton.layer.shadowOpacity = 0.35
        okButton.layer.shadowRadius = 12
        okButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        okButton.addTarget(self, action: #selector(dismissWalletSwitchPopup), for: .touchUpInside)

        let okLabel = UILabel()
        okLabel.translatesAutoresizingMaskIntoConstraints = false
        okLabel.text = "OK"
        okLabel.textAlignment = .center
        okLabel.textColor = .white
        okLabel.font = UIFont.avenir(size: 15)
        okLabel.isUserInteractionEnabled = false

        overlay.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(messageLabel)
        card.addSubview(okButton)
        okButton.addSubview(okLabel)
        hostView.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: hostView.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: hostView.bottomAnchor),

            card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: overlay.leadingAnchor, constant: 28),
            card.trailingAnchor.constraint(lessThanOrEqualTo: overlay.trailingAnchor, constant: -28),

            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),

            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            okButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 52),
            okButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -52),
            okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 18),
            okButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            okButton.heightAnchor.constraint(equalToConstant: 44),

            okLabel.leadingAnchor.constraint(equalTo: okButton.leadingAnchor),
            okLabel.trailingAnchor.constraint(equalTo: okButton.trailingAnchor),
            okLabel.topAnchor.constraint(equalTo: okButton.topAnchor),
            okLabel.bottomAnchor.constraint(equalTo: okButton.bottomAnchor)
        ])

        hostView.layoutIfNeeded()
        addWalletSwitchPopupGradient(to: card)
        addWalletSwitchButtonGradient(to: okButton)
        okButton.bringSubviewToFront(okLabel)

        card.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut], animations: {
            overlay.alpha = 1
            card.transform = .identity
        })
    }

    private func addWalletSwitchPopupGradient(to card: UIView) {
        let gradient = CAGradientLayer()
        gradient.name = "WalletSwitchPopupGradient"
        gradient.frame = card.bounds
        gradient.cornerRadius = card.layer.cornerRadius
        gradient.colors = [
            UIColor(rgb: 0x06020D).cgColor,
            UIColor(rgb: 0x24103A).cgColor,
            UIColor(rgb: 0x14051F).cgColor
        ]
        gradient.locations = [0.0, 0.58, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        card.layer.insertSublayer(gradient, at: 0)
    }

    private func addWalletSwitchButtonGradient(to button: UIView) {
        let gradient = CAGradientLayer()
        gradient.name = "WalletSwitchButtonGradient"
        gradient.frame = button.bounds
        gradient.cornerRadius = button.layer.cornerRadius
        gradient.colors = [
            UIColor(rgb: 0xFF3DF2).cgColor,
            UIColor(rgb: 0x6E2BFF).cgColor,
            UIColor(rgb: 0x00F5D4).withAlphaComponent(0.82).cgColor
        ]
        gradient.locations = [0.0, 0.56, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        button.layer.insertSublayer(gradient, at: 0)
    }

    @objc private func dismissWalletSwitchPopup() {
        guard let hostView = navigationController?.view ?? view else {
            return
        }

        guard let overlay = hostView.viewWithTag(walletSwitchPopupTag) else {
            return
        }

        UIView.animate(withDuration: 0.16, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
        })
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
