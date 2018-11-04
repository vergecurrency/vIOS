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

    @IBOutlet weak var xvgCardContainer: UIView!
    @IBOutlet weak var xvgCardImageView: UIImageView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCodeContainerView: UIView!
    @IBOutlet weak var cardAddress: UILabel!

    @IBOutlet weak var addressTextField: SelectorButton!
    @IBOutlet weak var amountTextField: SelectorButton!
    @IBOutlet weak var stealthSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let address = "1NMcHbiZuUYU9su1BDKTRtJvxnq14Z8YiT"

        qrCodeContainerView.layer.cornerRadius = 10.0
        qrCodeContainerView.clipsToBounds = true

        cardAddress.text = address

        addTapRecognizer(target: addressTextField, action: #selector(copyAddress(recognizer:)))
        addTapRecognizer(target: xvgCardImageView, action: #selector(copyAddress(recognizer:)))

        DispatchQueue.main.async {
            self.addressTextField.valueLabel?.text = address
            self.amountTextField.valueLabel?.text = NSNumber(value: 0.0).toXvgCurrency(fractDigits: 6)
            self.createQRCode(address: address, stealth: self.stealthSwitch.isOn)
        }
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

    func createQRCode(address: String, stealth: Bool = false) {
        var qrCode = QRCode(address)

        if stealth {
            qrCode?.color = CIColor(cgColor: UIColor.backgroundBlue().cgColor)
            qrCode?.backgroundColor = CIColor(cgColor: UIColor.primaryDark().cgColor)
        } else {
            qrCode?.color = .white
            qrCode?.backgroundColor = CIColor(cgColor: UIColor(red: 0.11, green: 0.62, blue: 0.83, alpha: 1.0).cgColor)
        }

        qrCodeImageView.image = (qrCode?.image)!
    }

    @IBAction func switchStealth(_ sender: UISwitch) {
        createQRCode(address: cardAddress.text!, stealth: sender.isOn)

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
        UIPasteboard.general.string = cardAddress.text
        NotificationManager.shared.showMessage("Address copied!", duration: 3)
    }
}
