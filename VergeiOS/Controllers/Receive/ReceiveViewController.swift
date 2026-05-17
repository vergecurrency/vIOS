//
//  ReceiveViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable
class ReceiveViewController: ThemeableViewController {

    enum CurrencySwitch {
        case XVG
        case FIAT
    }

    @IBOutlet weak var xvgCardContainer: UIView!
    @IBOutlet weak var xvgCardImageView: UIImageView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeContainerView: UIView!
    @IBOutlet weak var cardAddress: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var addressTextField: SelectorButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountTextField: CurrencyInput!
    @IBOutlet weak var stealthSwitch: UISwitch!

    var applicationRepository: ApplicationRepository!
    var walletClient: WalletClientProtocol!
    var transactionManager: TransactionManager!
    var currentQrCode: QRCode?

    var address = ""
    var amount = 0.0
    var currency = CurrencySwitch.XVG
    var cardShown = false
    private var didCenterEntryRows = false
    private weak var copyAddressButton: UIButton?

    override func updateColors() {
        super.updateColors()
        self.currencyLabel.textColor = ThemeManager.shared.secondaryLight()

        if self.currentQrCode != nil {
            self.currentQrCode?.color = CIColor(cgColor: ThemeManager.shared.currentTheme.qrCodeColor.cgColor)
            self.qrCodeImageView.image = (self.currentQrCode?.image)!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.xvgCardContainer.alpha = 0.0

        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            self.xvgCardContainer.center.y += 20.0
        }

        self.setAddress()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didSwitchWalletProfile(notification:)),
            name: .didSwitchWalletProfile,
            object: nil
        )

        self.qrCodeContainerView.layer.cornerRadius = 10.0
        self.qrCodeContainerView.clipsToBounds = true

        self.addTapRecognizer(target: xvgCardImageView, action: #selector(copyAddress(recognizer:)))
        self.addressTextField.addTarget(self, action: #selector(copyAddressFromButton), for: .touchUpInside)

        self.amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingDidEnd)
        self.setupAmountTextFieldKeyboardToolbar()
        self.styleEntryFields()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if cardShown && address.count > 0 {
            cardShown = false
            DispatchQueue.main.async {
                self.xvgCardContainer.alpha = 0.0
                self.xvgCardContainer.center.y += 20.0
                self.showCard()
            }
        }
        self.styleEntryFields()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        centerEntryRows()
        setupCopyAddressButton()
    }

    private func styleEntryFields() {
        addressTextField.label = "Address"
        addressTextField.usesSideLabelLayout = true

        if let selector = amountTextField.superview?.subviews.compactMap({ $0 as? SelectorButton }).first {
            selector.label = "\(currencyLabel.text ?? "XVG") Amount"
            selector.usesSideLabelLayout = true
        }

        amountTextField.backgroundColor = .clear
        amountTextField.layer.borderWidth = 0
        amountTextField.layer.cornerRadius = 0
        amountTextField.clipsToBounds = false
        amountTextField.contentVerticalAlignment = .bottom
        amountTextField.textColor = ThemeManager.shared.secondaryDark()
        amountTextField.tintColor = ThemeManager.shared.primaryLight()
        amountTextField.attributedPlaceholder = NSAttributedString(
            string: amountTextField.placeholder ?? "",
            attributes: [.foregroundColor: ThemeManager.shared.secondaryLight()]
        )
        currencyLabel.textColor = ThemeManager.shared.primaryLight()

        amountTextField.leftView = nil
        amountTextField.leftViewMode = .never
    }

    private func centerEntryRows() {
        guard !didCenterEntryRows else {
            return
        }

        didCenterEntryRows = true
        centerEntryRow(for: addressTextField)
        centerEntryRow(for: amountTextField)
    }

    private func centerEntryRow(for control: UIView?) {
        guard let fieldContainer = control?.superview,
            let row = fieldContainer.superview
        else {
            return
        }

        row.subviews
            .filter { $0 !== fieldContainer }
            .compactMap { $0 as? UIButton }
            .forEach { button in
                button.isHidden = true
                button.constraints
                    .filter { $0.firstAttribute == .width }
                    .forEach { $0.constant = 0 }
            }

        row.constraints
            .filter { constraint in
                let firstIsContainer = constraint.firstItem as? UIView === fieldContainer
                let secondIsContainer = constraint.secondItem as? UIView === fieldContainer
                let firstIsHiddenButton = (constraint.firstItem as? UIButton)?.isHidden == true
                let secondIsHiddenButton = (constraint.secondItem as? UIButton)?.isHidden == true

                return (firstIsContainer || secondIsContainer) && (firstIsHiddenButton || secondIsHiddenButton)
            }
            .forEach { $0.isActive = false }

        fieldContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fieldContainer.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            fieldContainer.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            fieldContainer.topAnchor.constraint(equalTo: row.topAnchor),
            fieldContainer.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
    }

    func showCard() {
        if cardShown {
            return
        }

        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        xvgCardContainer.alpha = 0.0

        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.xvgCardContainer.alpha = 1.0
            self.xvgCardContainer.center.y -= 20.0
        }, completion: { (_) in
            let image = self.imageCard()
            let imageData = image!.pngData()

            if imageData != nil {
                let defaults = UserDefaults(suiteName: "group.org.verge.wallet")
                defaults?.set(imageData!, forKey: "wallet.receive.image.shared")
            }
        })

        cardShown = true
    }

    func hideCard() {
        if !cardShown {
            return
        }

        activityIndicator.startAnimating()
        activityIndicator.isHidden = false

        xvgCardContainer.alpha = 1.0

        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.xvgCardContainer.alpha = 0.0
            self.xvgCardContainer.center.y += 20.0
        }, completion: nil)

        cardShown = false
    }

    func setAddress() {
        DispatchQueue.main.async {
            self.hideCard()
            self.address = ""
            self.cardAddress.text = ""
            self.addressTextField.value = ""
            self.addressTextField.valueLabel?.text = ""
            self.qrCodeImageView.image = nil

            var options = Vws.WalletAddressesOptions()
            options.limit = 1
            options.reverse = true

            self.walletClient.getMainAddresses(options: options) { error, addresses in
                if let error = error {
                    return self.showAddressError(error: error)
                }

                guard let lastAddress = addresses.first else {
                    return self.getNewAddress()
                }

                if self.transactionManager.all(byAddress: lastAddress.address).count == 0 {
                    return self.handleChangeAddress(lastAddress.address)
                }

                self.getNewAddress()
            }
        }
    }

    @objc func didSwitchWalletProfile(notification: Notification? = nil) {
        setAddress()
    }

    func getNewAddress() {
        self.walletClient.createAddress { error, addressInfo, errorResponse in
            if errorResponse?.error == .MainAddressGapReached {
                let alert = UIAlertController.createAddressGapReachedAlert()

                self.present(alert, animated: true)

                return
            }

            guard let addressInfo = addressInfo else {
                return self.showAddressError(error:
                    error ?? NSError(domain: "No address could be created", code: 500, userInfo: nil)
                )
            }

            self.handleChangeAddress(addressInfo.address)
        }
    }

    func handleChangeAddress(_ address: String) {
        self.changeAddress(address)

        DispatchQueue.main.async {
            self.showCard()
        }
    }

    func changeAddress(_ address: String) {
        self.address = address

        NotificationCenter.default.post(name: .didChangeReceiveAddress, object: address)

        DispatchQueue.main.async {
            self.cardAddress.text = address
            self.addressTextField.value = address
            self.addressTextField.valueLabel?.text = address
            self.addressTextField.valueLabel?.textColor = .white
            self.createQRCode()
        }
    }

    private func setupCopyAddressButton() {
        guard copyAddressButton?.superview != addressTextField else {
            addressTextField.bringSubviewToFront(copyAddressButton!)
            return
        }

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Copy")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.accessibilityLabel = "Copy address"
        button.backgroundColor = UIColor(rgb: 0x3A125C)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.72).cgColor
        button.addTarget(self, action: #selector(copyAddressFromButton), for: .touchUpInside)

        addressTextField.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24),
            button.trailingAnchor.constraint(equalTo: addressTextField.trailingAnchor, constant: -2),
            button.topAnchor.constraint(equalTo: addressTextField.topAnchor, constant: -4)
        ])

        copyAddressButton = button
        addressTextField.bringSubviewToFront(button)
    }

    @objc func createQRCode() {
        let address = amount > 0.0 ? "verge:\(self.address)?amount=\(amount)" : self.address
        self.currentQrCode = QRCode(address)

        if stealthSwitch.isOn {
            self.currentQrCode?.color = CIColor(cgColor: ThemeManager.shared.backgroundBlue().cgColor)
            self.currentQrCode?.backgroundColor = CIColor(cgColor: ThemeManager.shared.primaryDark().cgColor)
        } else {
            self.currentQrCode?.color = CIColor(cgColor: ThemeManager.shared.currentTheme.qrCodeColor.cgColor)
            self.currentQrCode?.backgroundColor = .white
        }

        qrCodeImageView.image = (self.currentQrCode?.image)!
    }

    func imageCard() -> UIImage? {
        var image: UIImage?

        UIGraphicsBeginImageContextWithOptions(xvgCardContainer.bounds.size, false, 0.0)
        xvgCardImageView.clipsToBounds = true
        xvgCardContainer.drawHierarchy(in: xvgCardContainer.bounds, afterScreenUpdates: true)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        xvgCardImageView.clipsToBounds = false

        return image
    }

    @IBAction func newAddress(_ sender: UIButton) {
        getNewAddress()
    }

    @IBAction func switchCurrency(_ sender: Any) {
        self.currency = (self.currency == .XVG) ? .FIAT : .XVG
        var newAmount = ""
        if let xvgInfo = self.applicationRepository.latestRateInfo {
            if self.currency == .XVG {
                self.currencyLabel.text = "XVG"
                newAmount = String(Int(self.amount * 100))
            } else {
                self.currencyLabel.text = self.applicationRepository.currency
                newAmount = String(Int((self.amount * 100) * xvgInfo.price))
            }
        }

        amountTextField.text = newAmount.currencyInputFormatting()
        styleEntryFields()
    }

    @IBAction func shareAddress(_ sender: UIButton) {
        openShareSheet(shareText: "receive.myAddressTitle".localized + ": \(address)", shareImage: self.imageCard())
    }

    @IBAction func switchStealth(_ sender: UISwitch) {
        changeAddress(address)

        if sender.isOn {
            xvgCardImageView.image = UIImage(named: "StealthReceiveCard")
        } else {
            xvgCardImageView.image = UIImage(named: "ReceiveCard")
        }
    }

    func addTapRecognizer(target: UIView, action: Selector) {
        let gesture = UITapGestureRecognizer(target: self, action: action)
        gesture.numberOfTapsRequired = 1

        target.addGestureRecognizer(gesture)
    }

    @objc func copyAddress(recognizer: UIGestureRecognizer) {
        copyCurrentAddress()
    }

    @objc func copyAddressFromButton() {
        copyCurrentAddress()
    }

    private func copyCurrentAddress() {
        guard !address.isEmpty else {
            return
        }

        UIPasteboard.general.string = address
        NotificationBar.shared.showMessage("addresses.addressCopied".localized, duration: 3)
    }

    func openShareSheet(shareText text: String?, shareImage: UIImage?) {
        var objectsToShare = [Any]()

        if let shareTextObj = text {
            objectsToShare.append(shareTextObj)
        }

        if let shareImageObj = shareImage {
            objectsToShare.append(shareImageObj)
        }

        if text != nil || shareImage != nil {
            let activityViewController = UIActivityViewController(
                activityItems: objectsToShare,
                applicationActivities: nil
            )
            activityViewController.popoverPresentationController?.sourceView = self.view

            present(activityViewController, animated: true)
        } else {
            print("There is nothing to share")
        }
    }

    @objc func amountTextFieldDidChange(_ textField: CurrencyInput) {
        self.amount = textField.getNumber().doubleValue

        if currency == .FIAT {
            if let xvgInfo = self.applicationRepository.latestRateInfo {
                self.amount /= xvgInfo.price
            }
        }

        self.createQRCode()
    }

    private func setupAmountTextFieldKeyboardToolbar() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.tintColor = .white
        keyboardToolbar.barTintColor = UIColor(rgb: 0x12071A)
        keyboardToolbar.backgroundColor = UIColor(rgb: 0x12071A)
        keyboardToolbar.isTranslucent = false

        let doneButton = UIButton(type: .system)
        doneButton.setTitle(nil, for: .normal)
        doneButton.backgroundColor = UIColor(rgb: 0x3A125C)
        doneButton.layer.cornerRadius = 8
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.72).cgColor
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 18, bottom: 6, right: 18)
        doneButton.addTarget(self, action: #selector(dismissAmountKeyboard), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        let doneLabel = UILabel()
        doneLabel.text = "Done"
        doneLabel.textColor = .white
        doneLabel.font = UIFont.avenir(size: 15).demiBold()
        doneLabel.textAlignment = .center
        doneLabel.translatesAutoresizingMaskIntoConstraints = false
        doneLabel.isUserInteractionEnabled = false
        doneButton.addSubview(doneLabel)

        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(equalToConstant: 86),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneLabel.centerXAnchor.constraint(equalTo: doneButton.centerXAnchor),
            doneLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            doneLabel.leadingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: 12),
            doneLabel.trailingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: -12)
        ])

        let doneBarButton = UIBarButtonItem(customView: doneButton)
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardToolbar.items = [flexBarButton, doneBarButton]

        self.amountTextField.inputAccessoryView = keyboardToolbar
    }

    @objc private func dismissAmountKeyboard() {
        amountTextField.resignFirstResponder()
        amountTextFieldDidChange(amountTextField)
    }

    private func showAddressError(error: Error) {
        ErrorView.showError(error: error, bind: self.view) {
            self.setAddress()
        }
    }
}
