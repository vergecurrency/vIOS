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

        setupTextFieldBar()
        updateView(index: index)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        keyTextField.becomeFirstResponder()
    }

    private func setupTextFieldBar() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.tintColor = UIColor.primaryLight()

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

        keyTextField.inputAccessoryView = keyboardToolbar
        keyTextField.delegate = self
    }
    
    private func createLabelText(index: Int) -> String {
        return "Enter word #\(index + 1)"
    }
    
    private func createProgressText(index: Int) -> String {
        return "\(index + 1) out of \(numberOfWords)"
    }
    
    private func createPlaceholderText(index: Int) -> String {
        return "Key #\(index + 1) (e.g. Cat)"
    }
    
    private func updateView(index: Int) {
        print(keys)
        keyLabel.text = createLabelText(index: index)
        keyTextField.text = keys.indices.contains(index) ? keys[index] : ""
        keyTextField.placeholder = createPlaceholderText(index: index)
        keyProgressLabel.text = createProgressText(index: index)

        guard let toolbar = keyTextField.inputAccessoryView as? UIToolbar else {
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
        
        keys.insert(text!, at: index)
        return true
    }

    @objc func previousClick() {
        keys.removeLast()
        index = index - 1
        updateView(index: index)
    }
    
    @objc func nextClick() {
        let isAdded: Bool = addKeyToList(text: keyTextField.text)
        
        if index < numberOfWords - 1 {
            if isAdded {
                index = index + 1
                updateView(index: index)
            } else {
                keyTextField.shake()
                return
            }
        } else {
            performSegue(withIdentifier: "showFinalRecovery", sender: self)
        }
        
    }

    func setMnemonicAndProceed(_ mnemonic: [String]) {
        keys = mnemonic

        performSegue(withIdentifier: "showFinalRecovery", sender: self)
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
        nextClick()

        return true
    }
}
