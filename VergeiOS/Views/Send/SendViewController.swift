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

    let transactionFee = 0.1
    var currency = CurrencySwitch.XVG
    var sendTransaction = SendTransaction()
    
    var confirmButtonInterval: Timer?

    var walletAmount: NSNumber {
        return WalletManager.default.amount
    }

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

        if walletAmount.doubleValue <= transactionFee {
            noBalanceView.isHidden = false
        }

        self.xvgCardContainer.alpha = 0.0
        self.xvgCardContainer.center.y += 20.0

        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.xvgCardContainer.alpha = 1.0
            self.xvgCardContainer.center.y -= 20.0
        }, completion: nil)

        updateWalletAmountLabel()
        updateAmountLabel()
    }

    @objc func didReceiveStats(_ notification: Notification) {
        updateAmountLabel()
        updateWalletAmountLabel()
    }

    @IBAction func switchCurrency(_ sender: Any) {
        currency = (currency == .XVG) ? .FIAT : .XVG

        self.updateWalletAmountLabel()
        self.updateAmountLabel()
    }

    func updateWalletAmountLabel() {
        var amount = NSNumber(floatLiteral: walletAmount.doubleValue - sendTransaction.amount.doubleValue - transactionFee)
        if currency == .FIAT {
            amount = convertXvgToFiat(amount)
        }

        self.walletAmountLabel.text = amount.toCurrency(currency: getCurrencyString())
    }

    func updateAmountLabel() {
        self.amountTextField.valueLabel?.text = currentAmount().toCurrency(
            currency: getCurrencyString(),
            fractDigits: 6
        )
    }

    func convertXvgToFiat(_ amount: NSNumber) -> NSNumber {
        if let xvgInfo = PriceTicker.shared.xvgInfo {
            return NSNumber(value: amount.doubleValue * xvgInfo.raw.price)
        }

        return amount
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
            vc.sendTransaction = sendTransaction
        }
    }

    func isSendable() {
        let enabled = sendTransaction.amount.doubleValue > 0.0 && selectedRecipientAddress() != ""

        confirmButton.isEnabled = enabled
        confirmButton.backgroundColor = (enabled ? UIColor.primaryLight() : UIColor.vergeGrey())
    }

    @IBAction func confirm(_ sender: Any) {
        let confirmSendView = Bundle.main.loadNibNamed(
            "ConfirmSendView",
            owner: self,
            options: nil
        )?.first as! ConfirmSendView

        confirmSendView.setTransaction(sendTransaction)
        let alertController = confirmSendView.makeActionSheet()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let sendAction = UIAlertAction(title: "Send XVG", style: .default) { alert in
            self.sendXvg()
        }
        sendAction.setValue(UIImage(named: "Send"), forKey: "image")

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
            let newWalletAmount = NSNumber(
                floatLiteral: self.walletAmount.doubleValue - self.sendTransaction.amount.doubleValue - self.transactionFee
            )
            WalletManager.default.amount = newWalletAmount

            self.didSelectRecipientAddress("")
            self.didChangeAmount(SendTransaction())
            self.memoTextField.text = ""
        }

        present(unlockView, animated: true)
    }

    // MARK: - Recipients

    func didSelectRecipientAddress(_ address: String) {
        self.recipientTextField.valueLabel?.text = address
        sendTransaction.address = address
    }

    func selectedRecipientAddress() -> String {
        return sendTransaction.address
    }


    // MARK: - Amounts
    func didChangeAmount(_ transaction: SendTransaction) {
        self.sendTransaction = transaction

        updateAmountLabel()
        updateWalletAmountLabel()
    }

    func currentAmount() -> NSNumber {
        return currency == .FIAT ? sendTransaction.fiatAmount : sendTransaction.amount
    }

    func currentCurrency() -> String {
        return getCurrencyString()
    }
}
