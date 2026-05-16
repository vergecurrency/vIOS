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

    var txFactory: WalletTransactionFactory!
    var nfcTxFactory: NFCWalletTransactionFactory!
    var txTransponder: TxTransponderProtocol!
    var applicationRepository: ApplicationRepository!
    var ratesClient: RatesClient!
    var walletClient: WalletClientProtocol!
    var waitingForConfirmationPopover: Bool = false
    var loadingAlert: UIAlertController = UIAlertController.loadingAlert(title: "alerts.refreshRates.title".localized)

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

        self.confirmButton.backgroundColor = ThemeManager.shared.vergeGrey()
        self.confirmButtonInterval = setInterval(1) {
            self.isSendable()
        }

        self.amountTextField.delegate = self
        self.amountTextField.addTarget(
            self,
            action: #selector(amountChanged),
            for: .editingChanged
        )
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

        self.txFactory.updated { tx in
            self.loadingAlert.dismiss(animated: true)
            self.txUpdated(tx: tx)
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
        self.refreshWalletAmount()
    }

    @objc func didReceiveFiatRatings(_ notification: Notification) {
        self.updateWalletAmountLabel()
    }

    @objc func didChangeWalletAmount(notification: Notification) {
        DispatchQueue.main.async {
            self.noBalanceView.isHidden = (self.walletAmount.doubleValue > 0)
            self.updateWalletAmountLabel()
            self.updateAmountLabel()
        }
    }

    @objc func switchCurrency(_ sender: Any) {
        self.txFactory.currency = (self.txFactory.currency == .XVG) ? .FIAT : .XVG

        self.txFactory.update().then { _ in
            self.currencyLabel.text = self.txFactory.currency == .XVG ? "XVG" : self.txFactory.fiatCurrency
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

            currencyController.selectedCurrency = self.txFactory.fiatCurrency
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

    func txUpdated(tx: WalletTransactionFactory) {
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

        self.recipientTextField.text = tx.address
        self.memoTextField.text = tx.memo

        if tx.currency == .FIAT {
            self.currencyLabel.text = tx.fiatCurrency
        }

        self.updateAmountLabel()
        self.updateWalletAmountLabel()
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
            if !self.amountTextField.isFirstResponder {
                self.amountTextField.setAmount(self.txFactory.currentAmount())
            }

            if self.walletAmount.doubleValue == 0.0 {
                return
            }

            if (self.txFactory.amount.doubleValue > self.walletAmount.doubleValue) {
                self.amountTextField.textColor = ThemeManager.shared.vergeRed()

                self.notifySelectedToMuchAmount()
            } else {
                self.amountTextField.textColor = ThemeManager.shared.secondaryDark()
            }
        }
    }

    private func refreshWalletAmount() {
        let profileId = self.applicationRepository.activeWalletProfileId

        self.walletClient.getBalance { _, info in
            guard self.applicationRepository.activeWalletProfileId == profileId,
                let info = info
            else {
                return
            }

            self.applicationRepository.amount = info.availableAmountValue
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
        syncTransactionFields()

        // Selected amount is higher then nothing.
        // Selected amount is lower then wallet amount.
        // Address is set.
        let selectedAmount = self.txFactory.amount.doubleValue
        let selectedSatoshis = Int64((selectedAmount * Constants.satoshiDivider).rounded())
        let walletSatoshis = Int64((self.walletAmount.doubleValue * Constants.satoshiDivider).rounded())

        let enabled = selectedSatoshis > 0
            && selectedSatoshis <= walletSatoshis
            && self.txFactory.address != ""
            && self.waitingForConfirmationPopover == false

        self.confirmButton.isEnabled = enabled
        self.confirmButton.backgroundColor = (
            enabled ? ThemeManager.shared.primaryLight() : ThemeManager.shared.vergeGrey()
        )
    }

    @IBAction func confirm(_ sender: Any) {
        syncTransactionFields()

        self.resolveRecipientIfNeeded { resolved in
            guard resolved else {
                return
            }

            self.presentConfirmSend()
        }
    }

    private func syncTransactionFields() {
        self.txFactory.address = self.recipientTextField.text ?? self.txFactory.address
        self.txFactory.memo = self.memoTextField.text ?? self.txFactory.memo

        let amount = self.amountTextField.getNumber()
        if self.txFactory.currency == .XVG {
            self.txFactory.amount = amount
        } else {
            self.txFactory.fiatAmount = amount
        }
    }

    private func presentConfirmSend() {
        let confirmSendView = Bundle.main.loadNibNamed(
            "ConfirmSendView",
            owner: self,
            options: nil
        )?.first as! ConfirmSendView

        let alertController = confirmSendView.makeActionSheet()
        if UIDevice.current.userInterfaceIdiom == .pad, let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []

            self.waitingForConfirmationPopover = true
        } else {
            self.present(alertController, animated: true)
        }

        getTxProposal { proposal in
            guard let txTransponder = self.txTransponder ?? Application.container.resolve(TxTransponderProtocol.self) else {
                return alertController.dismiss(animated: true) {
                    self.showTransactionError(
                        Vws.TxProposalErrorResponse(
                            code: "500",
                            message: "The send service is not ready. Please reopen the send tab and try again."
                        ),
                        txp: nil
                    )
                }
            }

            self.txTransponder = txTransponder

            txTransponder.create(proposal: proposal) { txp, errorResponse, error in
                self.waitingForConfirmationPopover = false

                guard let txp = txp else {
                    if let error = error {
                        return alertController.dismiss(animated: true) {
                            self.showTransactionError(
                                Vws.TxProposalErrorResponse(code: "500", message: error.localizedDescription),
                                txp: nil
                            )
                        }
                    }

                    return alertController.dismiss(animated: true) {
                        self.showTransactionError(errorResponse, txp: nil)
                    }
                }

                do {
                    try confirmSendView.setup(txp)
                } catch {
                    return alertController.dismiss(animated: true) {
                        self.showTransactionError(
                            Vws.TxProposalErrorResponse(
                                code: "500",
                                message: "The wallet service returned an incomplete transaction proposal."
                            ),
                            txp: nil
                        )
                    }
                }

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

    private func resolveRecipientIfNeeded(completion: @escaping (Bool) -> Void) {
        let recipient = self.recipientTextField.text ?? self.txFactory.address

        AddressValidator().validateOrResolve(string: recipient) { valid, address, _, _, _, error in
            DispatchQueue.main.async {
                guard valid, let address = address else {
                    self.showInvalidAddressAlert(error: error)
                    return completion(false)
                }

                self.txFactory.address = address
                self.recipientTextField.text = address
                completion(true)
            }
        }
    }

    func getTxProposal(completion: @escaping (_ proposal: Vws.TxProposal) -> Void) {
        if txFactory.amount.doubleValue <= walletAmount.doubleValue {
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
                amount: NSNumber(value: Double(info.amount) / Constants.satoshiDivider)
            ).then { _ in
                completion(Vws.TxProposal(
                    address: self.txFactory.address,
                    amount: self.txFactory.amount,
                    message: self.txFactory.memo
                ))
            }
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
                    if let errorResponse = errorResponse {
                        thrownError = errorResponse
                    } else if let error = error {
                        thrownError = Vws.TxProposalErrorResponse(code: "500", message: error.localizedDescription)
                    }

                    if let thrownError = thrownError {
                        actionSheet.dismiss(animated: true) {
                            self.showTransactionError(thrownError, txp: txp)
                        }
                        return
                    }

                    self.txFactory.reset().then { _ in
                        _ = setTimeout(3.0) {
                            actionSheet.dismiss(animated: true)
                        }
                    }
                }
            }
        }

        self.present(unlockView, animated: true)
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
            amount: NSNumber(value: amount)
        ).then { _ in }
    }

    @objc func setMaximumAmount() {
        self.txFactory.setBy(amount: self.walletAmount).then { _ in }
    }

    @objc func clearTransactionDetails() {
        self.txFactory.reset().then { _ in }
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

        self.recipientTextField.inputAccessoryView = keyboardToolbar
        self.recipientTextField.delegate = self
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

        self.amountTextField.inputAccessoryView = keyboardToolbar
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

        self.memoTextField.inputAccessoryView = keyboardToolbar
        self.memoTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()

        return false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.amountTextField {
            self.txFactory.amount = 0.0
            self.txFactory.fiatAmount = 0.0
            self.didChangeSendTransaction(self.txFactory)
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

        AddressValidator().validateOrResolve(string: address) { valid, address, _, _, _, error in
            DispatchQueue.main.async {
                if !valid {
                    return self.showInvalidAddressAlert(error: error)
                }

                guard let address = address else {
                    return self.showInvalidAddressAlert(error: error)
                }

                self.txFactory.address = address

                self.didChangeSendTransaction(self.txFactory)
            }
        }
    }

    @objc func clearRecipient() {
        self.txFactory.address = ""

        self.didChangeSendTransaction(txFactory)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)

        self.didChangeSendTransaction(txFactory)
    }

    func showInvalidAddressAlert(error: AddressValidator.ResolutionError? = nil) {
        let message: String
        switch error {
        case .missingApiToken:
            message = "Unstoppable Domains API token is not configured."
        case .httpStatus(let status):
            message = "Unstoppable Domains lookup failed with HTTP \(status)."
        case .emptyResponse:
            message = "Unstoppable Domains returned an empty response."
        case .noRecords:
            message = "That Web3 name has no crypto records."
        case .recordNotFound:
            message = "That Web3 name does not have a crypto.XVG.address record."
        case .invalidJson:
            message = "Unstoppable Domains returned a response this app could not read."
        case .invalidResolvedAddress:
            message = "That Web3 name resolved, but not to a valid Verge address."
        case .none:
            message = "send.enterValidAddress".localized
        }

        let alert = UIAlertController(
            title: "send.wrongAddress".localized + " 🤷‍♀️",
            message: message,
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
        if !self.loadingAlert.isBeingPresented {
            self.present(self.loadingAlert, animated: true)
        }

        self.txFactory.address = transaction.address
        self.txFactory.memo = transaction.memo
        self.txFactory.currency = transaction.currency
        self.txFactory.amount = transaction.amount
        self.txFactory.fiatAmount = transaction.fiatAmount
        self.txFactory.fiatCurrency = transaction.fiatCurrency

        self.txFactory.update().then { tx in
            self.currencyLabel.text = tx.currency == .XVG ? "XVG" : tx.fiatCurrency
        }
    }

    func getSendTransaction() -> WalletTransactionFactory {
        return self.txFactory
    }
}

extension SendViewController: CurrencyDelegate {
    func didSelectCurrency(currency: String, sender: Any?) {
        if !self.loadingAlert.isBeingPresented {
            self.present(self.loadingAlert, animated: true)
        }

        self.txFactory.currency = .FIAT

        self.txFactory.setBy(fiatCurrency: currency).then { _ in
            self.currencyLabel.text = currency

            guard let controller = sender as? UIViewController else {
                return
            }

            controller.dismiss(animated: true)
        }
    }
}
// swiftlint:enable file_length type_body_length
