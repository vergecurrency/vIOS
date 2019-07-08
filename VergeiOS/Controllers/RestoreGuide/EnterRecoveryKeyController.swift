//
//  EnterRecoveryKeyController.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 29.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class EnterRecoveryKeyController: AbstractRestoreViewController {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var keyProgressLabel: UILabel!

    private let numberOfWords = 12
    private var index: Int = 0
    private var keys: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTextFieldBar()
        self.updateView(index: self.index)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.keyTextField.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.keys.count == self.numberOfWords {
            self.keys = []
            self.index = 0
            self.updateView(index: self.index)
        }
    }

    private func setupTextFieldBar() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.tintColor = ThemeManager.shared.primaryLight()

        let previousButton = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(EnterRecoveryKeyController.previousClick)
        )

        let nextButton = UIBarButtonItem(
            image: UIImage(named: "ArrowRight"),
            style: .plain,
            target: self,
            action: #selector(EnterRecoveryKeyController.nextClick)
        )

        keyboardToolbar.items = [
            previousButton,
            nextButton
        ]

        self.keyTextField.inputAccessoryView = keyboardToolbar
        self.keyTextField.delegate = self
    }

    private func createLabelText(index: Int) -> String {
        return "paperKey.enterWord".localized + " #\(index + 1)"
    }

    private func createProgressText(index: Int) -> String {
        return "\(index + 1) " + "paperKey.outOf".localized + " \(numberOfWords)"
    }

    private func createPlaceholderText(index: Int) -> String {
        return "paperKey.key".localized + " #\(index + 1) " + "paperKey.egCat".localized
    }

    private func updateView(index: Int) {
        self.keyLabel.text = self.createLabelText(index: index)
        self.keyTextField.text = self.keys.indices.contains(index) ? keys[index] : ""
        self.keyTextField.placeholder = self.createPlaceholderText(index: index)
        self.keyProgressLabel.text = self.createProgressText(index: index)

        guard let toolbar = self.keyTextField.inputAccessoryView as? UIToolbar else {
            return
        }

        if let previousButton = toolbar.items?.first {
            previousButton.isEnabled = (index > 0)
        }
    }

    private func addKeyToList(text: String?) -> Bool {
        if text == nil || text!.count == 0 {
            return false
        }

        self.keys.insert(text!, at: index)
        return true
    }

    @objc func previousClick() {
        self.keys.removeLast()
        self.index -= 1
        updateView(index: self.index)
    }

    @objc func nextClick() {
        let isAdded: Bool = self.addKeyToList(text: self.keyTextField.text)

        if !isAdded {
            self.keyTextField.shake()

            return
        }

        if self.index < self.numberOfWords - 1 {
            self.index += 1
            self.updateView(index: self.index)
        }

        if self.keys.count == self.numberOfWords {
            print(self.keys)
            self.performSegue(withIdentifier: "showFinalRecovery", sender: self)
        }
    }

    func setMnemonicAndProceed(_ mnemonic: [String]) {
        self.keys = mnemonic

        self.performSegue(withIdentifier: "showFinalRecovery", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if (segue.identifier == "scanQrCode") {
            let scanQrController = segue.destination as? PaperkeyQRViewController
            scanQrController?.paperkeyViewController = self
        }

        if (segue.identifier == "showFinalRecovery") {
            let finalRecoverController = segue.destination as? FinalRecoveryController
            finalRecoverController?.keys = self.keys
        }
    }
}

extension EnterRecoveryKeyController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nextClick()

        return true
    }
}
