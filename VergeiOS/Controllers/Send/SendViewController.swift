//
//  SendViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

// swiftlint:disable file_length type_body_length
class SendViewController: ThemeableViewController {

    enum CurrencySwitch {
        case XVG
        case FIAT
    }

    @IBOutlet weak var xvgCardContainer: UIView!
    @IBOutlet weak var noBalanceView: UIView!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var fiatWalletAmountLabel: UILabel!
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencySwitchBtn: UIButton!
    @IBOutlet weak var amountTextField: CurrencyInput!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var nfcInitiator: UIButton!

    var currency = CurrencySwitch.XVG
    var selectedFiatCurrency: String!
    var txFactory: WalletTransactionFactory!
    var nfcTxFactory: NFCWalletTransactionFactory!
    var txTransponder: TxTransponderProtocol!
    var applicationRepository: ApplicationRepository!
    var ratesClient: RatesClient!
    var walletClient: WalletClientProtocol!
    var waitingForConfirmationPopover: Bool = false

    weak var confirmButtonInterval: Timer?

    var walletAmount: NSNumber {
        return applicationRepository.amount
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override func updateColors() {
        super.updateColors()
        self.currencyLabel.textColor = ThemeManager.shared.secondaryLight()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectedFiatCurrency = self.applicationRepository.currency

        self.confirmButton.backgroundColor = ThemeManager.shared.vergeGrey()
        self.confirmButtonInterval = setInterval(1) {
            self.isSendable()
        }

        self.amountTextField.delegate = self
        self.amountTextField.addTarget(
            self,
            action: #selector(amountChanged),
            for: .editingDidEnd
        )

        self.setupRecipientTextFieldKeyboardToolbar()
        self.setupAmountTextFieldKeyboardToolbar()
        self.setupMemoTextFieldKeyboardToolbar()

        // Setup Currency Gestures
        self.setupCurrencyGestures()

        DispatchQueue.main.async {
            self.updateAmountLabel()
            self.updateWalletAmountLabel()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveFiatRatings),
            name: .didReceiveFiatRatings,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeWalletAmount),
            name: .didChangeWalletAmount,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshCurrency),
            name: .didChangeCurrency,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.noBalanceView.isHidden = (walletAmount.doubleValue > 0)
        self.nfcInitiator.isHidden = !self.nfcTxFactory.isNfcAvailable()

        self.xvgCardContainer.alpha = 0.0
        self.xvgCardContainer.center.y += 20.0

        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.xvgCardContainer.alpha = 1.0
            self.xvgCardContainer.center.y -= 20.0
        }, completion: nil)

        self.updateWalletAmountLabel()
        self.updateAmountLabel()
    }

    @objc func didReceiveFiatRatings(_ notification: Notification) {
        self.updateAmountLabel()
        self.updateWalletAmountLabel()
    }

    @objc func didChangeWalletAmount(notification: Notification) {
        DispatchQueue.main.async {
            self.noBalanceView.isHidden = (self.walletAmount.doubleValue > 0)
        }

        if (self.walletAmount.doubleValue > 0) {
            self.updateWalletAmountLabel()
        }
    }

    @objc func switchCurrency(_ sender: Any) {
        self.currency = (self.currency == .XVG) ? .FIAT : .XVG
        self.currencyLabel.text = self.currency == .XVG ? "XVG" : self.selectedFiatCurrency

        if self.currency == .XVG {
            self.getSendTransaction().fiatCurrency = nil
        }

        self.updateWalletAmountLabel()
        self.updateAmountLabel()
    }

    @objc func refreshCurrency(_ sender: Any) {
        DispatchQueue.main.async {
            self.updateWalletAmountLabel()
            self.updateAmountLabel()
        }
    }

    @objc func handleLongCurrencySwitchPress(
        sender: UILongPressGestureRecognizer
    ) {
        if (sender.state == .began) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            let navController = UIStoryboard.createFromStoryboardWithNavigationController(
                name: "Settings",
                type: CurrencyTableViewController.self
            )

            guard let currencyController = navController.viewControllers.first as? CurrencyTableViewController else {
                return
            }

            currencyController.selectedCurrency = self.selectedFiatCurrency
            currencyController.delegate = self

            self.present(navController, animated: true)
        }
    }

    func setupCurrencyGestures() {
        // When user taps on the button normally
        let tapCurrencyGesture = UITapGestureRecognizer(
            target: self,
            action: #selector (switchCurrency)
        )

        // When user long presses on the button.
        let longCurrencyGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongCurrencySwitchPress)
        )

        tapCurrencyGesture.numberOfTapsRequired = 1
        currencySwitchBtn.addGestureRecognizer(tapCurrencyGesture)
        currencySwitchBtn.addGestureRecognizer(longCurrencyGesture)
    }

    func updateWalletAmountLabel() {
        let sendAmount = txFactory.amount.doubleValue
        var amount = NSNumber(
            value: walletAmount.doubleValue - sendAmount
        )

        if amount.decimalValue < 0.0 {
            amount = NSNumber(value: 0.0)
        }

        let fiat = self.convertXvgToFiat(amount)

        DispatchQueue.main.async {
            self.walletAmountLabel.text = amount.toXvgCurrency()
            self.fiatWalletAmountLabel.text = (fiat != nil) ? "≈ \(fiat!.toCurrency())" : ""
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
                self.amountTextField.textColor = ThemeManager.shared.vergeRed()

                self.notifySelectedToMuchAmount()
            } else {
                self.amountTextField.textColor = ThemeManager.shared.secondaryDark()
            }
        }
    }

    func convertXvgToFiat(_ amount: NSNumber) -> NSNumber? {
        if let xvgInfo = self.applicationRepository.latestRateInfo {
            return NSNumber(value: amount.doubleValue * xvgInfo.price)
        }

        return nil
    }

    @IBAction func initiateNfc(_ sender: Any) {
        self.nfcTxFactory.initiateScan()
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
        let enabled = self.txFactory.amount.doubleValue > 0.0
            && self.txFactory.amount.doubleValue <= self.walletAmount.doubleValue
            && self.txFactory.address != ""
            && self.waitingForConfirmationPopover == false

        self.confirmButton.isEnabled = enabled
        self.confirmButton.backgroundColor = (
            enabled ? ThemeManager.shared.primaryLight() : ThemeManager.shared.vergeGrey()
        )
    }

    @IBAction func confirm(_ sender: Any) {
        let confirmSendView = Bundle.main.loadNibNamed(
            "ConfirmSendView",
            owner: self,
            options: nil
        )?.first as! ConfirmSendView

        let alertController = confirmSendView.makeActionSheet()
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []

            self.waitingForConfirmationPopover = true
        } else {
            self.present(alertController, animated: true)
        }

        getTxProposal { proposal in
            self.txTransponder.create(proposal: proposal) { txp, errorResponse, _ in
                self.waitingForConfirmationPopover = false

                guard let txp = txp else {
                    return alertController.dismiss(animated: true) {
                        self.showTransactionError(errorResponse, txp: nil)
                    }
                }

                confirmSendView.setup(txp)

                let sendAction = UIAlertAction(title: "send.sendXVG".localized, style: .default) { _ in
                    self.send(txp: txp)
                }
                sendAction.setValue(UIImage(named: "Send"), forKey: "image")

                alertController.addAction(sendAction)
                alertController.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))

                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.present(alertController, animated: true)
                }
            }
        }
    }

    func getTxProposal(completion: @escaping (_ proposal: Vws.TxProposal) -> Void) {
        if txFactory.amount.doubleValue < walletAmount.doubleValue {
            return completion(Vws.TxProposal(
                address: txFactory.address,
                amount: txFactory.amount,
                message: txFactory.memo
            ))
        }

        self.walletClient.getSendMaxInfo { info, _ in
            guard let info = info else {
                return self.present(UIAlertController.createSendMaxInfoAlert(), animated: true)
            }

            self.txFactory.setBy(
                currency: "XVG",
                fiatCurrency: self.selectedFiatCurrency,
                amount: NSNumber(value: Double(info.amount) / Constants.satoshiDivider)
            )

            completion(Vws.TxProposal(
                address: self.txFactory.address,
                amount: self.txFactory.amount,
                message: self.txFactory.memo
            ))
        }
    }

    func send(txp: Vws.TxProposalResponse) {
        let unlockView = PinUnlockViewController.createFromStoryBoard()
        unlockView.fillPinFor = .sending
        unlockView.cancelable = true
        unlockView.completion = { aunthenticated in
            unlockView.dismiss(animated: true)

            if !aunthenticated {
                return
            }

            let sendingView = Bundle.main.loadNibNamed(
                "SendingView",
                owner: self
            )?.first as! SendingView

            let actionSheet = sendingView.makeActionSheet()
            actionSheet.centerPopoverController(to: self.view)

            self.present(actionSheet, animated: true) {
                self.txTransponder.send(txp: txp) { txp, errorResponse, error  in
                    var thrownError: Vws.TxProposalErrorResponse?
                    if let error = error {
                        thrownError = Vws.TxProposalErrorResponse(code: "500", message: error.localizedDescription)
                    } else if let errorResponse = errorResponse {
                        thrownError = errorResponse
                    }

                    if let thrownError = thrownError {
                        actionSheet.dismiss(animated: true) {
                            self.showTransactionError(thrownError, txp: txp)
                        }
                        return
                    }

                    self.didChangeSendTransaction(
                        WalletTransactionFactory(ratesClient: self.ratesClient)
                    )

                    _ = setTimeout(3.0) {
                        actionSheet.dismiss(animated: true)
                    }
                }
            }
        }

        present(unlockView, animated: true)
    }

    func showTransactionError(_ errorResponse: Vws.TxProposalErrorResponse?, txp: Vws.TxProposalResponse?) {
        let error: String = errorResponse != nil ? errorResponse!.message : "send.noConnection".localized

        let actionSheet = UIAlertController(
            title: "send.transactionFailed".localized,
            message: "send.transactionFailedMessage".localized + ": \(error)",
            preferredStyle: .actionSheet
        )

        actionSheet.centerPopoverController(to: self.view)
        actionSheet.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .destructive) { _ in
            guard let txp = txp else {
                return
            }

            self.walletClient.deleteTxProposal(txp: txp)
        })

        self.present(actionSheet, animated: true)
    }

    func notifySelectedToMuchAmount() {
        let amount = amountTextField.text ?? "..."
        let alert = UIAlertController(
            title: "send.notEnoughBalance".localized + " ⚖️🤔",
            message: "send.notEnoughBalanceMessage1".localized + " \(amount). " +
                     "send.notEnoughBalanceMessage2".localized,
            preferredStyle: .alert
        )

        let okButton = UIAlertAction(title: "defaults.ok".localized, style: .default, handler: nil)

        alert.addAction(okButton)

        present(alert, animated: true, completion: nil)
    }

    @objc func amountChanged(_ textField: CurrencyInput) {
        let amount = textField.getNumber().doubleValue
        self.txFactory.setBy(
            currency: self.currentCurrency(),
            fiatCurrency: self.selectedFiatCurrency,
            amount: NSNumber(value: amount)
        )
        self.didChangeSendTransaction(txFactory)
    }

    @objc func setMaximumAmount() {
        self.txFactory.setBy(currency: "XVG", fiatCurrency: self.selectedFiatCurrency, amount: walletAmount)
        self.didChangeSendTransaction(txFactory)
    }

    @objc func clearTransactionDetails() {
        self.didChangeSendTransaction(WalletTransactionFactory(ratesClient: self.ratesClient))
    }
}

extension SendViewController: UITextFieldDelegate {
    // MARK: - Recipient text field toolbar

    func setupRecipientTextFieldKeyboardToolbar() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.tintColor = ThemeManager.shared.primaryLight()

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
        keyboardToolbar.tintColor = ThemeManager.shared.primaryLight()

        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let maximumButton = UIBarButtonItem(
            title: "send.sendMax".localized,
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
        keyboardToolbar.tintColor = ThemeManager.shared.primaryLight()

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

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.amountTextField {
            txFactory.amount = 0.0
            txFactory.fiatAmount = 0.0
            didChangeSendTransaction(txFactory)
        }
        return true
    }

    @objc func openRecipientSelector() {
        performSegue(withIdentifier: "selectRecipient", sender: self)
    }

    @objc func pasteAddress() {
        guard let address = UIPasteboard.general.string else {
            return
        }

        AddressValidator().validate(string: address) { valid, address, _, _, _  in
            if !valid {
                return self.showInvalidAddressAlert()
            }

            guard let address = address else {
                return self.showInvalidAddressAlert()
            }

            self.txFactory.address = address

            self.didChangeSendTransaction(self.txFactory)
        }
    }

    @objc func clearRecipient() {
        txFactory.address = ""

        didChangeSendTransaction(txFactory)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)

        didChangeSendTransaction(txFactory)
    }

    func showInvalidAddressAlert() {
        let alert = UIAlertController(
            title: "send.wrongAddress".localized + " 🤷‍♀️",
            message: "send.enterValidAddress".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.ok".localized, style: .cancel))

        present(alert, animated: true)
    }

    @IBAction func didChangeRecipientTextField(_ textfield: UITextField) {
        guard let text = textfield.text else {
            return
        }

        txFactory.address = text
    }

    @IBAction func didChangeMemoTextField(_ textfield: UITextField) {
        guard let text = textfield.text else {
            return
        }

        txFactory.memo = text
    }
}

extension SendViewController: SendTransactionDelegate {
    // MARK: - Send Transaction Delegate

    func didChangeSendTransaction(_ transaction: WalletTransactionFactory) {
        self.txFactory = transaction

        self.recipientTextField.text = self.txFactory.address
        self.memoTextField.text = self.txFactory.memo

        let clearable = self.txFactory.amount.doubleValue > 0.0
            || self.txFactory.address != ""
            || self.txFactory.memo != ""

        if clearable {
            let clearButton = UIBarButtonItem(
                image: UIImage(named: "ClearTextField")!,
                style: .plain,
                target: self,
                action: #selector(SendViewController.clearTransactionDetails)
            )

            self.navigationItem.setRightBarButton(clearButton, animated: true)
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }

        /* Not entirely correct either, but at least it doesn't switch to FIAT every time you enter XVG */
        if (self.currentCurrency() == "XVG") {
            self.updateAmountLabel()
            self.updateWalletAmountLabel()
        } else {
            self.didSelectCurrency(currency: transaction.fiatCurrency!, sender: nil)
        }

        /*if let currency = transaction.fiatCurrency {
            self.didSelectCurrency(currency: currency, sender: nil)
        } else {
            self.updateAmountLabel()
            self.updateWalletAmountLabel()
        }*/
    }

    func getSendTransaction() -> WalletTransactionFactory {
        return self.txFactory
    }

    func currentAmount() -> NSNumber {
        return self.currency == .FIAT ? self.txFactory.fiatAmount : self.txFactory.amount
    }

    func currentCurrency() -> String {
        return self.currency == .XVG ? "XVG" : self.applicationRepository.currency
    }
}

extension SendViewController: CurrencyDelegate {
    func didSelectCurrency(currency: String, sender: Any?) {
        self.selectedFiatCurrency = currency
        self.currency = .FIAT
        self.currencyLabel.text = currency

        self.txFactory.update(currency: currency)
        self.updateWalletAmountLabel()
        self.updateAmountLabel()

        guard let controller = sender as? UIViewController else {
            return
        }

        controller.dismiss(animated: true)
    }
}

// swiftlint:enable file_length type_body_length
