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

    var previousPassphrase: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        passphraseTextfield.addTarget(self, action: #selector(validatePassphrase(_:)), for: .editingChanged)
        passphraseTextfield.becomeFirstResponder()
        passphraseTextfield.delegate = self
    }

    @objc func validatePassphrase(_ textField: UITextField) {
        proceedButton.isEnabled = false
        proceedButton.backgroundColor = UIColor.vergeGrey()

        if previousPassphrase == textField.text {
            proceedButton.isEnabled = true
            proceedButton.backgroundColor = UIColor.primaryLight()
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "proceed" {
            ApplicationRepository.default.passphrase = previousPassphrase
        }
    }

}
