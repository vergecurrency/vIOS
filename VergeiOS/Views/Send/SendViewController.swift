//
//  SendViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {

    enum CurrencySwitch {
        case XVG
        case FIAT
    }

    @IBOutlet weak var xvgCardContainer: UIView!
    @IBOutlet weak var noBalanceView: UIView!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    let transactionFee = 0.1
    var currency = CurrencySwitch.XVG
    var sendTransaction = SendTransaction()
    
    var confirmButtonInterval: Timer?

    var walletAmount: NSNumber {
        return ApplicationManager.default.amount
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

        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingDidEnd)
        amountTextField.text = amountTextField.text?.currencyInputFormatting()

        setupRecipientTextFieldKeyBoardToolbar()

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
        currencyLabel.text = currency == .XVG ? "XVG" : ApplicationManager.default.currency

        updateWalletAmountLabel()
        updateAmountLabel()
    }

    func updateWalletAmountLabel() {
        var amount = NSNumber(floatLiteral: walletAmount.doubleValue - sendTransaction.amount.doubleValue - transactionFee)
        if currency == .FIAT {
            amount = convertXvgToFiat(amount)
        }

        if amount.decimalValue < 0.0 {
            amount = NSNumber(value: 0.0)
        }
        
        DispatchQueue.main.async {
            self.walletAmountLabel.text = amount.toCurrency(currency: self.currentCurrency())
        }
    }

    func updateAmountLabel() {
        // Change the text color of the amount label when the selected amount is
        // more then the wallet amount.
        DispatchQueue.main.async {
            self.amountTextField.text = String(Int(self.currentAmount().doubleValue * 100)).currencyInputFormatting()
            
            if self.walletAmount.doubleValue == 0.0 {
                return
            }

            if (self.currentAmount().doubleValue >= self.walletAmount.doubleValue) {
                self.amountTextField.textColor = UIColor.vergeRed()
                
                self.notifySelectedToMuchAmount()
            } else {
                self.amountTextField.textColor = UIColor.secondaryDark()
            }
        }
    }

    func convertXvgToFiat(_ amount: NSNumber) -> NSNumber {
        if let xvgInfo = PriceTicker.shared.xvgInfo {
            return NSNumber(value: amount.doubleValue * xvgInfo.price)
        }

        return amount
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "scanQRCode" {
            let vc = segue.destination as! ScanQRCodeViewController
            vc.sendTransactionDelegate = self
        }

        if segue.identifier == "selectRecipient" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers.first as! SelectRecipientTableViewController
            vc.sendTransactionDelegate = self
        }
    }

    func isSendable() {
        // Selected amount is higher then nothing.
        // Selected amount is lower then wallet amount.
        // Address is set.
        let enabled = sendTransaction.amount.doubleValue > 0.0
            && sendTransaction.amount.doubleValue < walletAmount.doubleValue
            && sendTransaction.address != ""

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
            unlockView.dismiss(animated: true)

            if !aunthenticated {
                return
            }

            let proposal = TxProposal(
                address: self.sendTransaction.address,
                amount: self.sendTransaction.amount,
                message: self.sendTransaction.memo
            )

            let sendingView = Bundle.main.loadNibNamed(
                "SendingView",
                owner: self
            )?.first as! SendingView

            let actionSheet = sendingView.makeActionSheet()

            self.present(actionSheet, animated: true)

            TxTransponder(walletClient: WalletClient.shared).send(proposal: proposal) { txp, error  in
                self.didChangeSendTransaction(SendTransaction())

                let timeout = (error == nil) ? 3.0 : 0.0
                let _ = setTimeout(timeout) {
                    actionSheet.dismiss(animated: true)
                }
            }
        }

        present(unlockView, animated: true)
    }
    
    func notifySelectedToMuchAmount() {
        let amount = amountTextField.text ?? "..."
        let alert = UIAlertController(
            title: "That's Too Much! 🤔",
            message: "You do not have enough balance to send \(amount). Change the amount to send in order to proceed.",
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okButton)
        
        present(alert, animated: true, completion: nil)
    }

    @objc func amountTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }

    @objc func amountChanged(_ textField: UITextField) {
        let amount = textField.text?.currencyNumberValue().doubleValue ?? 0

        sendTransaction.setBy(currency: currentCurrency(), amount: NSNumber(value: amount))
        didChangeSendTransaction(sendTransaction)
    }
}

extension SendViewController: UITextFieldDelegate {
    // MARK: - Recipient text field toolbar

    fileprivate func setupRecipientTextFieldKeyBoardToolbar() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.tintColor = UIColor.primaryLight()

        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedBarButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedBarButton.width = 10

        let contactsButton = UIBarButtonItem(
            image: UIImage(named: "AddContact"),
            style: .plain,
            target: self,
            action: #selector(SendViewController.openRecipientSelector)
        )

        let pasteButton = UIBarButtonItem(
            image: UIImage(named: "Paste"),
            style: .plain,
            target: self,
            action: #selector(SendViewController.pasteAddress)
        )

        let clearButton = UIBarButtonItem(
            image: UIImage(named: "ClearTextField"),
            style: .plain,
            target: self,
            action: #selector(SendViewController.clearRecipient)
        )

        let doneBarButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(SendViewController.dissmissKeyboard)
        )

        keyboardToolbar.items = [
            contactsButton,
            fixedBarButton,
            pasteButton,
            fixedBarButton,
            clearButton,
            flexBarButton,
            doneBarButton
        ]

        recipientTextField.inputAccessoryView = keyboardToolbar
        recipientTextField.delegate = self

        memoTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dissmissKeyboard()

        return false
    }

    @objc func openRecipientSelector() {
        performSegue(withIdentifier: "selectRecipient", sender: self)
    }

    @objc func pasteAddress() {
        guard let address = UIPasteboard.general.string else {
            return
        }

        AddressValidator().validate(string: address) { valid, address, amount in
            if !valid {
                return self.showInvalidAddressAlert()
            }

            guard let address = address else {
                return self.showInvalidAddressAlert()
            }

            self.sendTransaction.address = address

            self.didChangeSendTransaction(self.sendTransaction)
        }
    }

    @objc func clearRecipient() {
        sendTransaction.address = ""

        didChangeSendTransaction(sendTransaction)
    }

    @objc func dissmissKeyboard() {
        view.endEditing(true)

        sendTransaction.address = recipientTextField.text ?? ""
        sendTransaction.memo = memoTextField.text ?? ""

        didChangeSendTransaction(sendTransaction)
    }

    func showInvalidAddressAlert() {
        let alert = UIAlertController(
            title: "Wrong Address 🤷‍♀️",
            message: "The entered address is an invalid Verge address. Please enter a valid verge address.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))

        present(alert, animated: true)
    }
}

extension SendViewController: SendTransactionDelegate {
    // MARK: - Send Transaction Delegate

    func didChangeSendTransaction(_ transaction: SendTransaction) {
        sendTransaction = transaction

        self.recipientTextField.text = sendTransaction.address
        self.memoTextField.text = sendTransaction.memo

        updateAmountLabel()
        updateWalletAmountLabel()
    }

    func getSendTransaction() -> SendTransaction {
        return sendTransaction
    }

    func currentAmount() -> NSNumber {
        return currency == .FIAT ? sendTransaction.fiatAmount : sendTransaction.amount
    }

    func currentCurrency() -> String {
        return currency == .XVG ? "XVG" : ApplicationManager.default.currency
    }
}
