//
//  PassphraseConfirmationViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 06/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PassphraseConfirmationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passphraseTextfield: UITextField!
    @IBOutlet weak var proceedButton: UIButton!

    var applicationRepository: ApplicationRepository!
    var previousPassphrase: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        passphraseTextfield.addTarget(self, action: #selector(validatePassphrase(_:)), for: .editingChanged)
        passphraseTextfield.becomeFirstResponder()
        passphraseTextfield.delegate = self
        applyReadableTheme()
    }

    @objc func validatePassphrase(_ textField: UITextField) {
        proceedButton.isEnabled = false
        proceedButton.backgroundColor = ThemeManager.shared.vergeGrey()

        if previousPassphrase == textField.text {
            proceedButton.isEnabled = true
            proceedButton.backgroundColor = ThemeManager.shared.primaryLight()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if previousPassphrase == textField.text {
            performSegue(withIdentifier: "proceed", sender: self)

            return true
        }

        textField.shake()
        textField.text = ""

        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "proceed" {
            applicationRepository.pendingSetupPassphrase = previousPassphrase
            applicationRepository.passphrase = previousPassphrase
        }
    }

    private func applyReadableTheme() {
        view.backgroundColor = UIColor(rgb: 0x080212)

        labels(in: view).forEach { label in
            label.textColor = label.font.pointSize >= 20
                ? ThemeManager.shared.primaryLight()
                : ThemeManager.shared.secondaryLight()
            label.backgroundColor = .clear
        }

        passphraseTextfield.textColor = .white
        passphraseTextfield.tintColor = ThemeManager.shared.primaryLight()
        passphraseTextfield.backgroundColor = UIColor(rgb: 0x12061F).withAlphaComponent(0.94)
        passphraseTextfield.layer.cornerRadius = 8
        passphraseTextfield.layer.borderWidth = 1
        passphraseTextfield.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.48).cgColor
        passphraseTextfield.attributedPlaceholder = NSAttributedString(
            string: passphraseTextfield.placeholder ?? "",
            attributes: [.foregroundColor: ThemeManager.shared.secondaryLight().withAlphaComponent(0.72)]
        )

        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.setTitleColor(UIColor.white.withAlphaComponent(0.72), for: .disabled)
        proceedButton.tintColor = .white
    }

    private func labels(in root: UIView) -> [UILabel] {
        var result = root.subviews.compactMap { $0 as? UILabel }

        for subview in root.subviews {
            result.append(contentsOf: labels(in: subview))
        }

        return result
    }
}
