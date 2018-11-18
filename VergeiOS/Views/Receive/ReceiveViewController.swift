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
class ReceiveViewController: UIViewController {

    enum CurrencySwitch {
        case XVG
        case FIAT
    }

    @IBOutlet weak var xvgCardContainer: UIView!
    @IBOutlet weak var xvgCardImageView: UIImageView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeContainerView: UIView!
    @IBOutlet weak var cardAddress: UILabel!

    @IBOutlet weak var addressTextField: SelectorButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var stealthSwitch: UISwitch!

    var address = ""
    var amount = 0.0
    var currency = CurrencySwitch.XVG

    override func viewDidLoad() {
        super.viewDidLoad()

        getNewAddress()

        qrCodeContainerView.layer.cornerRadius = 10.0
        qrCodeContainerView.clipsToBounds = true

        addTapRecognizer(target: addressTextField, action: #selector(copyAddress(recognizer:)))
        addTapRecognizer(target: xvgCardImageView, action: #selector(copyAddress(recognizer:)))
        
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.xvgCardContainer.alpha = 0.0
        self.xvgCardContainer.center.y += 20.0

        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.xvgCardContainer.alpha = 1.0
            self.xvgCardContainer.center.y -= 20.0
        }, completion: nil)
    }

    func getNewAddress() {
        WalletClient.shared.createAddress { error, addressInfo in
            guard let addressInfo = addressInfo else {
                return
            }

            self.changeAddress(addressInfo.address)
        }
    }

    func changeAddress(_ address: String) {
        self.address = address

        DispatchQueue.main.async {
            self.cardAddress.text = address
            self.addressTextField.valueLabel?.text = address
            self.createQRCode()
        }
    }

    func createQRCode() {
        let address = amount > 0.0 ? "verge://\(self.address)?amount=\(amount)" : self.address
        var qrCode = QRCode(address)

        if stealthSwitch.isOn {
            qrCode?.color = CIColor(cgColor: UIColor.backgroundBlue().cgColor)
            qrCode?.backgroundColor = CIColor(cgColor: UIColor.primaryDark().cgColor)
        } else {
            qrCode?.color = .white
            qrCode?.backgroundColor = CIColor(cgColor: UIColor(red: 0.11, green: 0.62, blue: 0.83, alpha: 1.0).cgColor)
        }

        qrCodeImageView.image = (qrCode?.image)!
    }

    @IBAction func newAddress(_ sender: UIButton) {
        getNewAddress()
    }

    @IBAction func amountChanged(_ sender: UITextField) {
        amount = sender.text?.currencyNumberValue().doubleValue ?? 0
        print(NSNumber(value: amount), amount, sender.text)

        if currency == .FIAT {
            if let xvgInfo = PriceTicker.shared.xvgInfo {
                amount = amount / xvgInfo.price
            }
        }

        createQRCode()
    }

    @IBAction func switchCurrency(_ sender: Any) {
        currency = (currency == .XVG) ? .FIAT : .XVG
        var newAmount = ""
        if let xvgInfo = PriceTicker.shared.xvgInfo {
            if currency == .XVG {
                currencyLabel.text = "XVG"
                newAmount = String(Int(amount * 100))
            } else {
                currencyLabel.text = ApplicationManager.default.currency
                newAmount = String(Int((amount * 100) * xvgInfo.price))
            }
        }

        amountTextField.text = newAmount.currencyInputFormatting()
    }

    @IBAction func shareAddress(_ sender: UIButton) {
        UIGraphicsBeginImageContextWithOptions(xvgCardContainer.bounds.size, false, 0.0)
        xvgCardImageView.clipsToBounds = true
        xvgCardContainer.drawHierarchy(in: xvgCardContainer.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        xvgCardImageView.clipsToBounds = false

        openShareSheet(shareText: "My XVG address: \(address)", shareImage: image)
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
        NotificationManager.shared.showMessage("Address copied!", duration: 3)
    }

    func openShareSheet(shareText text: String?, shareImage: UIImage?) {
        var objectsToShare = [Any]()

        if let shareTextObj = text {
            objectsToShare.append(shareTextObj)
        }

        if let shareImageObj = shareImage {
            objectsToShare.append(shareImageObj.pngData()!)
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
    
    @objc func amountTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
}
