//
//  FinishSetupViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 29-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Logging

class FinishSetupViewController: AbstractPaperkeyViewController {

    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var termOneSwitch: UISwitch!
    @IBOutlet weak var termTwoSwitch: UISwitch!
    @IBOutlet weak var termThreeSwitch: UISwitch!
    @IBOutlet weak var createWalletButton: UIButton!

    @IBOutlet weak var walletCreationView: UIView!
    @IBOutlet weak var checklistImage: UIImageView!
    @IBOutlet weak var checklistDescription: UILabel!
    @IBOutlet weak var openWalletButton: RoundedButton!

    var applicationRepository: ApplicationRepository!
    var credentials: Credentials!
    var walletManager: WalletManagerProtocol!
    var log: Logger!

    var agreedWithTerms: Bool = false
    weak var interval: Timer?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true

        self.createWalletButton.isEnabled = false
        self.createWalletButton.alpha = 0

        self.createWalletButton.isEnabled = false
        self.openWalletButton.alpha = 0

        styleTermsScreen()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateTermsButtonGradients()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.interval?.invalidate()
    }

    @IBAction func showTermsOfUse(sender: Any) {
        self.present(UIAlertController.createShowTermsOfUseAlert(), animated: true)
    }

    @IBAction func termSwitched(sender: Any) {
        self.hideWalletButton(button: self.createWalletButton)

        if termOneSwitch.isOn && termTwoSwitch.isOn && termThreeSwitch.isOn {
            self.showWalletButton(button: self.createWalletButton)
        }
    }

    @IBAction func setupWallet(sender: Any) {
        self.termsView.isHidden = true
        self.walletCreationView.isHidden = false

        guard let mnemonic = self.applicationRepository.mnemonic ?? self.applicationRepository.pendingRestoreMnemonic else {
            self.log.error("wallet setup no mnemonic found")

            return self.showSetupErrorAlert("No mnemonic found")
        }
        self.applicationRepository.mnemonic = mnemonic

        let passphrase: String
        if self.applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic) {
            guard let storedPassphrase = self.applicationRepository.pendingSetupPassphrase ?? self.applicationRepository.passphrase else {
                self.log.error("wallet setup no passphrase found")

                return self.showSetupErrorAlert("No passphrase found")
            }

            passphrase = storedPassphrase
            self.applicationRepository.saveSetupPassphrase(passphrase)
        } else {
            passphrase = ""
            self.applicationRepository.passphrase = nil
        }

        self.credentials.reset(mnemonic: mnemonic, passphrase: passphrase)

        if !self.applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic) {
            self.applicationRepository.finishWalletProfileSetup()
            return self.animateProgress()
        }

        self.walletManager
            .getWallet()
            .then { _ in
                self.applicationRepository.finishWalletProfileSetup()
                self.animateProgress()
            }.catch { error in
                self.showSetupErrorAlert(error.localizedDescription)
            }
    }

    private func animateProgress() {
        var selectedImage = 0
        let images = [
            "ChecklistTwoItem",
            "ChecklistThreeItem",
            "CheckmarkCircle"
        ]

        interval = setInterval(1) {
            self.checklistImage.image = UIImage(named: images[selectedImage])
            selectedImage += 1

            if selectedImage == images.count {
                self.interval?.invalidate()

                self.checklistDescription.text = "setup.finish.congrats".localized
                self.showWalletButton(button: self.openWalletButton)
            }
        }
    }

    private func showWalletButton(button: UIButton) {
        button.center.y += 30
        button.isEnabled = true

        UIView.animate(withDuration: 0.3) {
            button.alpha = 1
            button.center.y -= 30
        }
    }

    private func hideWalletButton(button: UIButton) {
        UIView.animate(withDuration: 0.3) {
            button.alpha = 0
            button.isEnabled = false
        }
    }

    private func styleTermsScreen() {
        termsView.backgroundColor = .clear

        allLabels(in: termsView).forEach { label in
            label.textColor = ThemeManager.shared.secondaryLight()
        }

        allButtons(in: termsView).forEach { button in
            styleTermsButton(button)
        }
    }

    private func updateTermsButtonGradients() {
        allButtons(in: termsView).forEach { button in
            addRetrowaveGradient(to: button, name: "RetrowaveTermsButtonGradient")
        }
    }

    private func styleTermsButton(_ button: UIButton) {
        if button.constraints.first(where: { $0.identifier == "RetrowaveTermsMinimumHeight" }) == nil {
            let minimumHeight = button.heightAnchor.constraint(greaterThanOrEqualToConstant: 42)
            minimumHeight.identifier = "RetrowaveTermsMinimumHeight"
            minimumHeight.isActive = true
        }

        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.82
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 18, bottom: 6, right: 18)
        button.titleEdgeInsets = .zero
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.72).cgColor
        button.layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = .zero
        button.clipsToBounds = false

        addRetrowaveGradient(to: button, name: "RetrowaveTermsButtonGradient")
    }

    private func addRetrowaveGradient(to button: UIButton, name: String) {
        button.layer.sublayers?
            .filter { $0.name == name }
            .forEach { $0.removeFromSuperlayer() }

        guard button.bounds.width > 0, button.bounds.height > 0 else {
            return
        }

        let gradient = CAGradientLayer()
        gradient.name = name
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
        button.layer.insertSublayer(gradient, at: 0)
    }

    private func allButtons(in root: UIView) -> [UIButton] {
        var buttons = root.subviews.compactMap { $0 as? UIButton }

        for subview in root.subviews {
            buttons.append(contentsOf: allButtons(in: subview))
        }

        return buttons
    }

    private func allLabels(in root: UIView) -> [UILabel] {
        var labels = root.subviews.compactMap { $0 as? UILabel }

        for subview in root.subviews {
            labels.append(contentsOf: allLabels(in: subview))
        }

        return labels
    }

    private func showSetupErrorAlert(_ message: String) {
        self.navigationController?.popViewController(animated: true)

        guard let controller = self.navigationController?.visibleViewController else {
            fatalError("Can't do anything with this")
        }

        let alert = UIAlertController.createWalletSetupErrorAlert(error: message) { _ in
            let supportController = UIStoryboard.createFromStoryboardWithNavigationController(
                name: "Settings",
                type: SupportTableViewController.self
            )

            controller.present(supportController, animated: true)
        }

        controller.present(alert, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        NotificationCenter.default.post(name: .didSetupWallet, object: nil)
    }

}
