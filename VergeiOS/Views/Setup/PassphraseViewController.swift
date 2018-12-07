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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (UIDevice.current.userInterfaceIdiom != .pad) {
            return .default
        }

        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.primaryLight()]
        navigationController?.navigationBar.tintColor = .primaryLight()
        navigationController?.navigationBar.barStyle = .default

        passphraseTextfield.addTarget(self, action: #selector(validatePassphrase(_:)), for: .editingChanged)
        passphraseTextfield.delegate = self
    }

    @objc func validatePassphrase(_ textField: UITextField) {
        proceedButton.isEnabled = false
        proceedButton.backgroundColor = UIColor.vergeGrey()

        charactersImage.tintColor = UIColor.secondaryLight()
        caseImage.tintColor = UIColor.secondaryLight()
        specialsImage.tintColor = UIColor.secondaryLight()

        guard let passphrase = textField.text else {
            return
        }

        let length = checkLength(passphrase)
        let cases = checkCase(passphrase)
        let specials = checkSpecials(passphrase)

        if length {
            charactersImage.tintColor = UIColor.vergeGreen()
        }

        if cases {
            caseImage.tintColor = UIColor.vergeGreen()
        }

        if specials {
            specialsImage.tintColor = UIColor.vergeGreen()
        }

        if (length && cases && specials) {
            proceedButton.isEnabled = true
            proceedButton.backgroundColor = UIColor.primaryLight()
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

    @objc func nice() {
        print("nice")
    }

    @IBAction func closeView(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "proceed" {
            if let vc = segue.destination as? PassphraseConfirmationViewController {
                vc.previousPassphrase = passphraseTextfield.text!
            }
        }
    }

}
