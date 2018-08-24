//
//  SendViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

enum CurrencySwitch {
    case XVG
    case FIAT
}

class SendViewController: UIViewController, RecipientDelegate, AmountDelegate {

    @IBOutlet weak var xvgCardContainer: UIView!
    @IBOutlet weak var noBalanceView: UIView!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var recipientTextField: SelectorButton!
    @IBOutlet weak var amountTextField: SelectorButton!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var currency = CurrencySwitch.XVG
    var walletAmount: NSNumber = WalletManager.default.amount
    var amount: NSNumber = 0.0
    
    var confirmButtonInterval: Timer?

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmButtonInterval = setInterval(1) {
            self.isSendable()
        }

        DispatchQueue.main.async {
            self.updateAmountLabel()
            self.updateWalletAmountLabel()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStats),
            name: .didReceiveStats,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.xvgCardContainer.alpha = 0.0
        self.xvgCardContainer.center.y += 20.0

        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.xvgCardContainer.alpha = 1.0
            self.xvgCardContainer.center.y -= 20.0
        }, completion: nil)

        updateWalletAmount()
        updateWalletAmountLabel()
        updateAmountLabel()
    }

    @objc func didReceiveStats(_ notification: Notification) {
        updateWalletAmount()
        updateAmountLabel()
        updateWalletAmountLabel()
    }

    @IBAction func switchCurrency(_ sender: UIBarButtonItem) {
        currency = (currency == .XVG) ? .FIAT : .XVG

        // Get current price.
        if let xvgInfo = PriceTicker.shared.xvgInfo {
            if currency == .XVG {
                sender.title = "XVG"
                amount = NSNumber(value: Double(truncating: amount) / xvgInfo.raw.price)
                walletAmount = NSNumber(value: Double(truncating: walletAmount) / xvgInfo.raw.price)
            } else {
                sender.title = WalletManager.default.currency
                amount = NSNumber(value: Double(truncating: amount) * xvgInfo.raw.price)
                walletAmount = NSNumber(value: Double(truncating: walletAmount) * xvgInfo.raw.price)
            }
        }

        self.updateWalletAmountLabel()
        self.updateAmountLabel()
    }

    func updateWalletAmount() {
        walletAmount = WalletManager.default.amount
    }

    func updateWalletAmountLabel() {
        let amountLeft = NSNumber(floatLiteral: walletAmount.doubleValue - amount.doubleValue - 0.1)
        self.walletAmountLabel.text = amountLeft.toCurrency(currency: getCurrencyString())
    }

    func updateAmountLabel() {
        self.amountTextField.valueLabel?.text = amount.toCurrency(currency: getCurrencyString(), fractDigits: 6)
    }

    func getCurrencyString() -> String {
        return currency == .XVG ? "XVG" : WalletManager.default.currency
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "scanQRCode" {
            let vc = segue.destination as! ScanQRCodeViewController
            vc.delegate = self
        }

        if segue.identifier == "selectRecipient" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers.first as! SelectRecipientTableViewController
            vc.delegate = self
        }

        if segue.identifier == "setAmount" {
            let vc = segue.destination as! SetAmountViewController
            vc.delegate = self
        }
    }

    func isSendable() {
        let enabled = currentAmount().doubleValue > 0.0 && selectedRecipientAddress() != ""

        confirmButton.isEnabled = enabled
        confirmButton.backgroundColor = (enabled ? UIColor.primaryLight() : UIColor.vergeGrey())
    }

    @IBAction func confirm(_ sender: Any) {
        let confirmSendView = Bundle.main.loadNibNamed(
            "ConfirmSendView",
            owner: self,
            options: nil
        )?.first as! ConfirmSendView

        let transaction = SendTransaction()
        transaction.amount = currentAmount()
        transaction.address = selectedRecipientAddress()

        confirmSendView.setTransaction(transaction)
        let alertController = confirmSendView.makeActionSheet()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let sendAction = UIAlertAction(title: "Send", style: .default) { alert in
            self.sendXvg()
        }

        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }

    func sendXvg() {
        let unlockView = PinUnlockViewController.createFromStoryBoard()
        unlockView.fillPinFor = .sending
        unlockView.cancelable = true
        unlockView.completion = { aunthenticated in
            if !aunthenticated {
                return unlockView.dismiss(animated: true)
            }

            unlockView.dismiss(animated: true)

            // TODO ofcourse...
            let newWalletAmount = NSNumber(floatLiteral: self.walletAmount.doubleValue - self.amount.doubleValue - 0.1)
            WalletManager.default.amount = newWalletAmount

            self.didSelectRecipientAddress("")
            self.didChangeAmount(0)
            self.updateWalletAmount()
            self.memoTextField.text = ""
        }

        present(unlockView, animated: true)
    }

    // MARK: - Recipients

    func didSelectRecipientAddress(_ address: String) {
        self.recipientTextField.valueLabel?.text = address
    }

    func selectedRecipientAddress() -> String {
        return recipientTextField.valueLabel?.text ?? ""
    }


    // MARK: - Amounts

    func didChangeAmount(_ amount: NSNumber) {
        self.amount = amount

        updateAmountLabel()
        updateWalletAmountLabel()
    }

    func currentAmount() -> NSNumber {
        return amount
    }

}
