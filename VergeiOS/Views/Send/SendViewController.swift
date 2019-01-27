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
    @IBOutlet weak var amountTextField: CurrencyInput!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    let transactionFee = Config.fee
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

        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingDidEnd)

        setupRecipientTextFieldKeyboardToolbar()
        setupAmountTextFieldKeyboardToolbar()
        setupMemoTextFieldKeyboardToolbar()

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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveTransaction),
            name: .didReceiveTransaction,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        noBalanceView.isHidden = (walletAmount.doubleValue >= transactionFee)

        xvgCardContainer.alpha = 0.0
        xvgCardContainer.center.y += 20.0

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
    
    @objc func didReceiveTransaction(notification: Notification) {
        DispatchQueue.main.async {
            self.noBalanceView.isHidden = (self.walletAmount.doubleValue >= self.transactionFee)
        }
    }

    @IBAction func switchCurrency(_ sender: Any) {
        currency = (currency == .XVG) ? .FIAT : .XVG
        currencyLabel.text = currency == .XVG ? "XVG" : ApplicationManager.default.currency

        updateWalletAmountLabel()
        updateAmountLabel()
    }

    func updateWalletAmountLabel() {
        let sendAmount = sendTransaction.amount.doubleValue > 0 ? (
            sendTransaction.amount.doubleValue + transactionFee
        ) : 0
        var amount = NSNumber(floatLiteral: walletAmount.doubleValue - sendAmount)
        if currency == .FIAT {
            amount = convertXvgToFiat(amount)
        }

        if amount.decimalValue < 0.0 {
            amount = NSNumber(value: 0.0)
        }
        
        DispatchQueue.main.async {
            self.walletAmountLabel.text = amount.toXvgCurrency()
        }
    }

    func updateAmountLabel() {
        // Change the text color of the amount label when the selected amount is
        // more then the wallet amount.
        DispatchQueue.main.async {
            self.amountTextField.setAmount(self.currentAmount())
            
            if self.walletAmount.doubleValue == 0.0 {
                return
            }

            if (self.currentAmount().doubleValue > self.walletAmount.doubleValue) {
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
            && sendTransaction.amount.doubleValue <= walletAmount.doubleValue
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

            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            self.present(actionSheet, animated: true) {
                TxTransponder(walletClient: WalletClient.shared).send(proposal: proposal) { txp, errorResponse, error  in
                    if let errorResponse = errorResponse {
                        actionSheet.dismiss(animated: true) {
                            self.showTransactionError(errorResponse, txp: txp)
                        }
                        return
                    }

                    self.didChangeSendTransaction(SendTransaction())

                    let timeout = (error == nil) ? 3.0 : 0.0
                    let _ = setTimeout(timeout) {
                        actionSheet.dismiss(animated: true)
                    }
                }
            }
        }

        present(unlockView, animated: true)
    }

    func showTransactionError(_ errorResponse: TxProposalErrorResponse, txp: TxProposalResponse?) {
        let actionSheet = UIAlertController(
            title: "Transaction Failed",
            message: "Your transaction has failed with the following error: \(errorResponse.message)",
            preferredStyle: .actionSheet
        )

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive) { action in
            if let txp = txp {
                WalletClient.shared.rejectTxProposal(txp: txp)
            }
        })

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(actionSheet, animated: true)
    }
    
    func notifySelectedToMuchAmount() {
        let amount = amountTextField.text ?? "..."
        let alert = UIAlertController(
            title: "Not enough balance ⚖️🤔",
            message: "You do not have enough balance to send \(amount). Change the amount to send in order to proceed.",
            preferredStyle: .alert
        )
        
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okButton)
        
        present(alert, animated: true, completion: nil)
    }

    @objc func amountChanged(_ textField: CurrencyInput) {
        let amount = textField.getNumber().doubleValue

        sendTransaction.setBy(currency: currentCurrency(), amount: NSNumber(value: amount))
        didChangeSendTransaction(sendTransaction)
    }

    @objc func setMaximumAmount() {
        sendTransaction.setBy(currency: "XVG", amount: NSNumber(value: walletAmount.doubleValue - transactionFee))
        didChangeSendTransaction(sendTransaction)
    }

    @objc func clearTransactionDetails() {
        didChangeSendTransaction(SendTransaction())
    }
}

extension SendViewController: UITextFieldDelegate {
    // MARK: - Recipient text field toolbar

    fileprivate func setupRecipientTextFieldKeyboardToolbar() {
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
            action: #selector(SendViewController.dismissKeyboard)
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
    }

    func setupAmountTextFieldKeyboardToolbar() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.tintColor = UIColor.primaryLight()

        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let maximumButton = UIBarButtonItem(
            title: "Send Max",
            style: .plain,
            target: self,
            action: #selector(SendViewController.setMaximumAmount)
        )

        let doneBarButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(SendViewController.dismissKeyboard)
        )

        keyboardToolbar.items = [
            maximumButton,
            flexBarButton,
            doneBarButton
        ]

        amountTextField.inputAccessoryView = keyboardToolbar
    }

    func setupMemoTextFieldKeyboardToolbar() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.tintColor = UIColor.primaryLight()

        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let doneBarButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(SendViewController.dismissKeyboard)
        )

        keyboardToolbar.items = [
            flexBarButton,
            doneBarButton
        ]

        memoTextField.inputAccessoryView = keyboardToolbar
        memoTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()

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

    @objc func dismissKeyboard() {
        view.endEditing(true)

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

    @IBAction func didChangeRecipientTextField(_ textfield: UITextField) {
        guard let text = textfield.text else {
            return
        }

        sendTransaction.address = text
    }

    @IBAction func didChangeMemoTextField(_ textfield: UITextField) {
        guard let text = textfield.text else {
            return
        }

        sendTransaction.memo = text
    }
}

extension SendViewController: SendTransactionDelegate {
    // MARK: - Send Transaction Delegate

    func didChangeSendTransaction(_ transaction: SendTransaction) {
        sendTransaction = transaction

        recipientTextField.text = sendTransaction.address
        memoTextField.text = sendTransaction.memo

        let clearable = sendTransaction.amount.doubleValue > 0.0
            || sendTransaction.address != ""
            || sendTransaction.memo != ""

        if clearable {
            let clearButton = UIBarButtonItem(
                image: UIImage(named: "ClearTextField")!,
                style: .plain,
                target: self,
                action: #selector(SendViewController.clearTransactionDetails)
            )

            navigationItem.setRightBarButton(clearButton, animated: true)
        } else {
            navigationItem.rightBarButtonItem = nil
        }

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
