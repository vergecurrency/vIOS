//
//  Created by Swen van Zanten on 29-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Logging

class ConfirmPaperkeyViewController: AbstractPaperkeyViewController, UITextFieldDelegate {

    @IBOutlet weak var firstWordLabel: UILabel!
    @IBOutlet weak var secondWordLabel: UILabel!

    @IBOutlet weak var firstWordTextfield: UITextField!
    @IBOutlet weak var secondWordTextfield: UITextField!

    var applicationRepository: ApplicationRepository!
    var log: Logger!

    var mnemonic: [String] = []
    var randomNumbers: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.randomNumbers = self.selectRandomNumbers()

        self.firstWordLabel.text = "paperKey.word".localized + " #\(randomNumbers.first!)"
        self.secondWordLabel.text = "paperKey.word".localized + " #\(randomNumbers.last!)"

        self.firstWordTextfield.delegate = self
        self.secondWordTextfield.delegate = self
        styleConfirmationForm()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        styleConfirmationForm()
    }

    func selectRandomNumbers() -> [Int] {
        var numbers: [Int] = []
        let wordCount = UInt32(max(mnemonic.count, 1))

        for _ in 1...2 {
            var number = Int(arc4random_uniform(wordCount) + 1)
            while numbers.contains(number) {
                number = Int(arc4random_uniform(wordCount) + 1)
            }

            numbers.append(number)
        }

        return numbers.sorted()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstWordTextfield {
            self.secondWordTextfield.becomeFirstResponder()

            return true
        }

        textField.resignFirstResponder()

        return true
    }

    @IBAction func submitPaperkeyConfirmation(_ sender: Any) {
        self.firstWordTextfield.updateColors()
        self.secondWordTextfield.updateColors()
        styleConfirmationForm()

        // Add shake effect...
        if self.firstWordTextfield.text != self.mnemonic[self.randomNumbers.first! - 1] {
            self.firstWordTextfield.backgroundColor = ThemeManager.shared.vergeRed().withAlphaComponent(0.15)
            return
        }

        if self.secondWordTextfield.text != self.mnemonic[self.randomNumbers.last! - 1] {
            self.secondWordTextfield.backgroundColor = ThemeManager.shared.vergeRed().withAlphaComponent(0.15)
            return
        }

        // Save the mnemonic.
        self.applicationRepository.mnemonic = mnemonic
        self.applicationRepository.passphrase = nil

        if self.applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic) {
            self.performSegue(withIdentifier: "finishWelcomeGuide", sender: self)
        } else {
            let controller = UIStoryboard.createFromStoryboard(name: "Setup", type: FinishSetupViewController.self)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    private func styleConfirmationForm() {
        let formBackground = UIColor(rgb: 0x080212)
        view.backgroundColor = formBackground

        if let formContainer = firstWordTextfield.superview {
            styleFormContainer(formContainer, background: formBackground)
        }

        firstWordLabel.textColor = ThemeManager.shared.primaryLight()
        secondWordLabel.textColor = ThemeManager.shared.primaryLight()

        styleInput(firstWordTextfield)
        styleInput(secondWordTextfield)
        styleActionButtons(in: view)
    }

    private func styleInput(_ textField: UITextField) {
        textField.textColor = .white
        textField.tintColor = ThemeManager.shared.primaryLight()
        textField.backgroundColor = UIColor(rgb: 0x12061F).withAlphaComponent(0.92)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.42).cgColor
        textField.attributedPlaceholder = NSAttributedString(
            string: textField.placeholder ?? "",
            attributes: [.foregroundColor: ThemeManager.shared.secondaryLight().withAlphaComponent(0.72)]
        )
    }

    private func styleFormContainer(_ root: UIView, background: UIColor) {
        if root is UILabel || root is UIButton {
            root.backgroundColor = .clear
        } else {
            root.backgroundColor = background
        }

        for subview in root.subviews {
            if subview is UITextField {
                continue
            }

            styleFormContainer(subview, background: background)
        }
    }

    private func styleActionButtons(in root: UIView) {
        allButtons(in: root).forEach { button in
            guard !(button is KeyboardButton) else {
                return
            }

            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(UIColor.white.withAlphaComponent(0.78), for: .disabled)
            button.tintColor = .white
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.72
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.lineBreakMode = .byClipping
            button.contentHorizontalAlignment = .center
            button.contentVerticalAlignment = .center
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.72).cgColor
            button.layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
            button.layer.shadowOpacity = 0.35
            button.layer.shadowRadius = 12
            button.layer.shadowOffset = .zero
            button.clipsToBounds = false
            if let titleLabel = button.titleLabel {
                button.bringSubviewToFront(titleLabel)
            }
        }
    }

    private func allButtons(in root: UIView) -> [UIButton] {
        var buttons = root.subviews.compactMap { $0 as? UIButton }

        for subview in root.subviews {
            buttons.append(contentsOf: allButtons(in: subview))
        }

        return buttons
    }

}
