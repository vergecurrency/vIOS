//
//  ReceiveViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import QRCode

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

        self.qrCodeContainerView.layer.cornerRadius = 10.0
        self.qrCodeContainerView.clipsToBounds = true

        self.addTapRecognizer(target: addressTextField, action: #selector(copyAddress(recognizer:)))
        self.addTapRecognizer(target: xvgCardImageView, action: #selector(copyAddress(recognizer:)))

        self.amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingDidEnd)
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
            self.addressTextField.valueLabel?.text = address
            self.createQRCode()
        }
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
        gesture.numberOfTapsRequired = 2

        target.addGestureRecognizer(gesture)
    }

    @objc func copyAddress(recognizer: UIGestureRecognizer) {
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

    private func showAddressError(error: Error) {
        ErrorView.showError(error: error, bind: self.view) {
            self.setAddress()
        }
    }
}
