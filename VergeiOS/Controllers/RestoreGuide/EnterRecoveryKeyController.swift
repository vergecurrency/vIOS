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

    private enum RestoreType {
        case legacyVws
        case electrumX

        var wordCount: Int {
            switch self {
            case .legacyVws:
                return 12
            case .electrumX:
                return 18
            }
        }

        var title: String {
            switch self {
            case .legacyVws:
                return "Legacy 12-word wallet"
            case .electrumX:
                return "ElectrumX 18-word wallet"
            }
        }
    }

    private var restoreType: RestoreType?
    private var didPresentRestoreTypeChooser = false
    private var numberOfWords: Int {
        return restoreType?.wordCount ?? ApplicationRepository.createdWalletMnemonicWordCount
    }
    private var index: Int = 0
    private var keys: [String] = []
    private weak var doneControl: UIButton?
    private lazy var doneButton = UIBarButtonItem(
        customView: makeNavigationTextButton(title: "defaults.done".localized, action: #selector(doneClick))
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTextFieldBar()
        self.setupNavigationButtons()
        self.updateView(index: self.index)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if restoreType == nil && !didPresentRestoreTypeChooser {
            self.presentRestoreTypeChooser()
        } else {
            self.keyTextField.becomeFirstResponder()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationButtons()

        if self.restoreType == nil || ApplicationRepository.supportedMnemonicWordCounts.contains(self.keys.count) {
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
        self.navigationItem.rightBarButtonItem = doneButton
        self.updateDoneButton()
    }

    private func setupNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: makeNavigationIconButton(symbol: "‹", accessibilityLabel: "Back", action: #selector(backClick))
        )
        navigationItem.rightBarButtonItem = doneButton
    }

    private func makeNavigationTextButton(title: String, action: Selector) -> UIButton {
        let button = makeNavigationButton(action: action)
        doneControl = button

        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = UIFont.avenir(size: 14).demiBold()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.72
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(label)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 58),
            button.heightAnchor.constraint(equalToConstant: 34),
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
        ])
        applyRoundRetrowaveStyle(to: button, cornerRadius: 17)

        return button
    }

    private func makeNavigationIconButton(symbol: String, accessibilityLabel: String, action: Selector) -> UIButton {
        let button = makeNavigationButton(action: action)
        button.accessibilityLabel = accessibilityLabel

        let label = UILabel()
        label.text = symbol
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(label)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34),
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -1)
        ])
        applyRoundRetrowaveStyle(to: button, cornerRadius: 17)

        return button
    }

    private func makeNavigationButton(action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        button.tintColor = .white

        DispatchQueue.main.async { [weak self, weak button] in
            guard let button = button else {
                return
            }

            self?.applyRoundRetrowaveStyle(to: button, cornerRadius: button.bounds.height / 2)
        }

        return button
    }

    private func applyRoundRetrowaveStyle(to button: UIButton, cornerRadius: CGFloat) {
        let gradientName = "RetrowaveRestoreNavigationButtonGradient"
        button.backgroundColor = UIColor(rgb: 0x12071A)
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(button.isEnabled ? 0.75 : 0.32).cgColor
        button.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        button.layer.shadowOpacity = button.isEnabled ? 0.38 : 0.12
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = .zero
        button.clipsToBounds = false

        button.layer.sublayers?
            .filter { $0.name == gradientName }
            .forEach { $0.removeFromSuperlayer() }

        guard button.bounds.width > 0 && button.bounds.height > 0 else {
            return
        }

        let gradient = CAGradientLayer()
        gradient.name = gradientName
        gradient.frame = button.bounds
        gradient.cornerRadius = cornerRadius
        gradient.colors = [
            UIColor(rgb: 0x14071F).withAlphaComponent(button.isEnabled ? 1.0 : 0.7).cgColor,
            UIColor(rgb: 0x3A125C).withAlphaComponent(button.isEnabled ? 1.0 : 0.62).cgColor,
            UIColor(rgb: 0x12071A).withAlphaComponent(button.isEnabled ? 1.0 : 0.7).cgColor
        ]
        gradient.locations = [0.0, 0.52, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        button.layer.insertSublayer(gradient, at: 0)
        button.subviews.forEach { button.bringSubviewToFront($0) }
    }

    private func presentRestoreTypeChooser() {
        didPresentRestoreTypeChooser = true

        let alert = UIAlertController(
            title: "Restore wallet type",
            message: "Choose the recovery phrase type for the wallet you are restoring.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: RestoreType.legacyVws.title, style: .default) { _ in
            self.setRestoreType(.legacyVws)
        })
        alert.addAction(UIAlertAction(title: RestoreType.electrumX.title, style: .default) { _ in
            self.setRestoreType(.electrumX)
        })

        self.present(alert, animated: true)
    }

    private func setRestoreType(_ restoreType: RestoreType) {
        self.restoreType = restoreType
        self.title = restoreType.title

        if keys.count > restoreType.wordCount {
            keys = Array(keys.prefix(restoreType.wordCount))
        }

        index = min(index, restoreType.wordCount - 1)
        updateView(index: index)
        keyTextField.becomeFirstResponder()
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

        updateDoneButton()
    }

    private func addKeyToList(text: String?) -> Bool {
        if text == nil || text!.count == 0 {
            return false
        }

        if self.keys.indices.contains(index) {
            self.keys[index] = text!
        } else {
            self.keys.insert(text!, at: index)
        }

        updateDoneButton()
        return true
    }

    private func updateDoneButton() {
        guard let restoreType = restoreType else {
            doneButton.isEnabled = false
            doneControl?.isEnabled = false
            doneControl?.alpha = 0.58
            if let doneControl = doneControl {
                applyRoundRetrowaveStyle(to: doneControl, cornerRadius: doneControl.bounds.height / 2)
            }
            return
        }

        doneButton.isEnabled = keys.count == restoreType.wordCount
        doneControl?.isEnabled = keys.count == restoreType.wordCount
        doneControl?.alpha = keys.count == restoreType.wordCount ? 1.0 : 0.58
        if let doneControl = doneControl {
            applyRoundRetrowaveStyle(to: doneControl, cornerRadius: doneControl.bounds.height / 2)
        }
    }

    @objc func backClick() {
        if let navigationController = navigationController,
           navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
            return
        }

        dismiss(animated: true)
    }

    @objc func previousClick() {
        if !self.keys.isEmpty {
            self.keys.removeLast()
        }
        self.index -= 1
        updateView(index: self.index)
    }

    @objc func nextClick() {
        let isAdded: Bool = self.addKeyToList(text: self.keyTextField.text)

        if !isAdded {
            self.keyTextField.shake()

            return
        }

        if self.keys.count == self.numberOfWords {
            self.performSegue(withIdentifier: "showFinalRecovery", sender: self)
            return
        }

        if self.index < self.numberOfWords - 1 {
            self.index += 1
            self.updateView(index: self.index)
        }
    }

    @objc func doneClick() {
        guard let restoreType = restoreType else {
            self.presentRestoreTypeChooser()
            return
        }

        if let text = self.keyTextField.text, !text.isEmpty, !self.keys.indices.contains(index) {
            _ = self.addKeyToList(text: text)
        }

        guard self.keys.count == restoreType.wordCount else {
            self.keyTextField.shake()
            return
        }

        self.performSegue(withIdentifier: "showFinalRecovery", sender: self)
    }

    func setMnemonicAndProceed(_ mnemonic: [String]) {
        if mnemonic.count == RestoreType.legacyVws.wordCount {
            self.restoreType = .legacyVws
        } else if mnemonic.count == RestoreType.electrumX.wordCount {
            self.restoreType = .electrumX
        }

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
