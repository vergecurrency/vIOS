//
//  PassphraseViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 05/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PassphraseViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passphraseTextfield: UITextField!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var charactersImage: UIImageView!
    @IBOutlet weak var caseImage: UIImageView!
    @IBOutlet weak var specialsImage: UIImageView!

    var applicationRepository: ApplicationRepository!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (UIDevice.current.userInterfaceIdiom != .pad) {
            return .default
        }

        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: ThemeManager.shared.primaryLight()]
        navigationController?.navigationBar.tintColor = ThemeManager.shared.primaryLight()
        navigationController?.navigationBar.barStyle = .default

        passphraseTextfield.addTarget(self, action: #selector(validatePassphrase(_:)), for: .editingChanged)
        passphraseTextfield.delegate = self
        applyReadableTheme()
    }

    @objc func validatePassphrase(_ textField: UITextField) {
        proceedButton.isEnabled = false
        proceedButton.backgroundColor = ThemeManager.shared.vergeGrey()

        charactersImage.tintColor = ThemeManager.shared.secondaryLight()
        caseImage.tintColor = ThemeManager.shared.secondaryLight()
        specialsImage.tintColor = ThemeManager.shared.secondaryLight()

        guard let passphrase = textField.text else {
            return
        }

        let length = checkLength(passphrase)
        let cases = checkCase(passphrase)
        let specials = checkSpecials(passphrase)

        if length {
            charactersImage.tintColor = ThemeManager.shared.vergeGreen()
        }

        if cases {
            caseImage.tintColor = ThemeManager.shared.vergeGreen()
        }

        if specials {
            specialsImage.tintColor = ThemeManager.shared.vergeGreen()
        }

        if (length && cases && specials) {
            proceedButton.isEnabled = true
            proceedButton.backgroundColor = ThemeManager.shared.primaryLight()
        }
    }

    func checkLength(_ passphrase: String) -> Bool {
        return passphrase.count >= 8
    }

    func checkCase(_ passphrase: String) -> Bool {
        do {
            let numberOfLowercases = try NSRegularExpression(pattern: "[a-z]+")
                .numberOfMatches(in: passphrase, range: NSRange(passphrase.startIndex..., in: passphrase))

            let numberOfUppercases = try NSRegularExpression(pattern: "[A-Z]+")
                .numberOfMatches(in: passphrase, range: NSRange(passphrase.startIndex..., in: passphrase))

            return numberOfLowercases > 0 && numberOfUppercases > 0
        } catch {
            print(error)
            return false
        }
    }

    func checkSpecials(_ passphrase: String) -> Bool {
        do {
            let numberOfSpecials = try NSRegularExpression(pattern: "[!@#$%^&*()_+-=\\[\\]{};':\"\\|,.<>/?]+")
                .numberOfMatches(in: passphrase, range: NSRange(passphrase.startIndex..., in: passphrase))

            return numberOfSpecials > 0
        } catch {
            print(error)
            return false
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let passphrase = textField.text else {
            return false
        }

        let length = checkLength(passphrase)
        let cases = checkCase(passphrase)
        let specials = checkSpecials(passphrase)

        if (length && cases && specials) {
            performSegue(withIdentifier: "proceed", sender: self)
        }

        return length && cases && specials
    }

    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "proceed" {
            let passphrase = self.passphraseTextfield.text!
            applicationRepository.pendingSetupPassphrase = passphrase
            applicationRepository.passphrase = passphrase

            if let vc = segue.destination as? PassphraseConfirmationViewController {
                vc.previousPassphrase = passphrase
            }
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
