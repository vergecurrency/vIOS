//
//  ElectrumMnemonicTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 25/01/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit
import BitcoinKit
import Promises
import Eureka

class ElectrumMnemonicTableViewController: EdgedFormViewController {

    var sweeperHelper: SweeperHelperProtocol!
    var loadingAlert: UIAlertController = UIAlertController.loadingAlert()
    var balancesLoaded: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.updateColors()

        self.tableView.tableHeaderView = TableHeaderView(
            title: "sweeping.electrum.titleLabel".localized,
            image: UIImage(named: "PrivateKeySweepingPlaceholder")!
        )

        let styleCell = { (cell: TextAreaCell) in
            cell.textLabel?.font = UIFont.avenir(size: 17)
            cell.textLabel?.textColor = ThemeManager.shared.secondaryDark()
            cell.textView?.font = UIFont.avenir(size: 17).demiBold()
            cell.textView?.textColor = ThemeManager.shared.secondaryDark()
            cell.textView?.autocorrectionType = .no
            cell.textView?.autocapitalizationType = .none
            cell.textView?.spellCheckingType = .no
            cell.textView?.smartDashesType = .no
            cell.textView?.smartInsertDeleteType = .no
            cell.textView?.smartQuotesType = .no
            cell.backgroundColor = ThemeManager.shared.backgroundWhite()
            cell.textLabel?.updateColors()
            cell.textView?.updateColors()
        }

        self.form +++ Section("sweeping.electrum.mnemonic".localized)
            <<< TextAreaRow("mnemonic") { row in
            row.title = "sweeping.electrum.mnemonic".localized
            row.add(rule: RuleRequired())
        }.cellUpdate { cell, _ in
            styleCell(cell)
        }
            <<< ButtonRow("submit") { row in
            row.title = "sweeping.electrum.sweep".localized
        }.onCellSelection { _, _ in
            let mnemonic = (self.form.rowBy(tag: "mnemonic") as! TextAreaRow).value ?? ""

            if !self.validateMnemonic(mnemonic: mnemonic) {
                return self.showInvalidMnemonicAlert()
            }

            self.prepareSweeping(mnemonic: mnemonic)
        }
    }

    private func sweep(keyBalances: [KeyBalance], toAddress address: String) {
        self.showLoadingAlert()
        self.loadingAlert.message = "Sweeping the Electrum mnemonic..."

        let filteredKeyBalances = keyBalances.filter { keyBalance in
            return keyBalance.balance.confirmed > 0
        }

        self.sweeperHelper.sweep(keyBalances: filteredKeyBalances, destinationAddress: address)
            .then { txid in
                let alert = UIAlertController(
                    title: "sweeping.privateKey.swept.title".localized,
                    message: "\("sweeping.privateKey.swept.description".localized):\n\n\(txid)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "defaults.done".localized, style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })

                self.dismissLoadingAlert().then { _ in
                    self.present(alert, animated: true)
                }
            }.catch { error in
                switch error {
                case PrivateKeyError.invalidFormat:
                    self.showInvalidMnemonicAlert()
                default:
                    self.showUnexpectedErrorAlert(error: error)
                }
            }
    }

    private func prepareSweeping(mnemonic: String) {
        let keys = self.getKeysFromMnemonic(mnemonic: mnemonic)

        let confirmSweepView = Bundle.main.loadNibNamed(
            "ConfirmSweepView",
            owner: self,
            options: nil
        )?.first as! ConfirmSweepView

        let alertController = confirmSweepView.makeActionSheet()
        alertController.centerPopoverController(to: self.view)

        self.loadingAlert.message = "Scanning balances 0/\(keys.count)"
        self.showLoadingAlert()

        var savedKeyBalances: [KeyBalance] = []
        var savedAmount: NSNumber?

        self.loadBalances(keys: keys)
            .then { keyBalances in
                let amount = NSNumber(value: Double(keyBalances.reduce(0, { result, keyBalance in
                    result + keyBalance.balance.confirmed
                })) / Constants.satoshiDivider)

                if amount == 0 {
                    throw SweeperHelper.Error.notEnoughBalance
                }

                self.dismissLoadingAlert().then { _ in
                    self.present(alertController, animated: true)
                }

                savedKeyBalances = keyBalances
                savedAmount = amount
            }
            .then { _ in
                return self.sweeperHelper.recipientAddress()
            }
            .then { address in
                confirmSweepView.setup(toAddress: address, amount: savedAmount!)

                let sendAction = UIAlertAction(title: "settings.sweeping.sweep".localized, style: .default) { _ in
                    self.sweep(keyBalances: savedKeyBalances, toAddress: address)
                }
                sendAction.setValue(UIImage(named: "Sweep"), forKey: "image")

                alertController.addAction(sendAction)
                alertController.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
            }
            .catch { error in
                switch error {
                case PrivateKeyError.invalidFormat:
                    self.showInvalidMnemonicAlert()
                case SweeperHelper.Error.notEnoughBalance:
                    self.showNotEnoughBalanceAlert()
                default:
                    self.showUnexpectedErrorAlert(error: error)
                }
            }
    }

    private func validateMnemonic(mnemonic: String) -> Bool {
        // Simply check if there are 8 or more spaces... improve check if needed.
        mnemonic.components(separatedBy: " ").count >= 8
    }

    private func getKeysFromMnemonic(mnemonic: String) -> [String] {
        let mnemonicData = mnemonic.decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let salt = ("electrum" + "").decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let seed = _Key.deriveKey(mnemonicData, salt: salt, iterations: 2048, keyLength: 64)

        let privateKey = HDPrivateKey(seed: seed, network: .mainnetXVG)

        let m0prv = try! privateKey.derived(at: 0)
        let m1prv = try! privateKey.derived(at: 1)

        var keys: [String] = []

        for i in 0..<20 {
            keys.append(try! m0prv.derived(at: UInt32(i)).privateKey().toWIF())
        }

        for i in 0..<6 {
            keys.append(try! m1prv.derived(at: UInt32(i)).privateKey().toWIF())
        }

        return keys
    }

    private func loadBalances(keys: [String]) -> Promise<[KeyBalance]> {
        self.balancesLoaded = 0

        var promises: [Promise<KeyBalance>] = []
        for key in keys {
            let promise = Promise<KeyBalance>(on: .global(qos: .background)) { fulfill, reject in
                do {
                    let privateKey = try self.sweeperHelper.wifToPrivateKey(wif: key)
                    let balance = try await(self.sweeperHelper.balance(privateKey: privateKey))

                    DispatchQueue.main.async {
                        self.balancesLoaded += 1
                        self.loadingAlert.message = "Scanning balances \(self.balancesLoaded)/\(keys.count)"
                    }

                    fulfill(KeyBalance(privateKey: privateKey, balance: balance))
                } catch {
                    reject(error)
                }
            }

            promises.append(promise)
        }

        return all(promises)
    }

    private func showNotEnoughBalanceAlert() {
        self.dismissLoadingAlert().then { _ in
            self.present(UIAlertController.createNotEnoughBalanceAlert(), animated: true)
        }
    }

    private func showInvalidMnemonicAlert() {
        self.dismissLoadingAlert().then { _ in
            self.present(UIAlertController.createInvalidMnemonicAlert(), animated: true)
        }
    }

    private func showUnexpectedErrorAlert(error: Error) {
        self.dismissLoadingAlert().then { _ in
            self.present(UIAlertController.createUnexpectedErrorAlert(error: error), animated: true)
        }
    }

    private func showLoadingAlert() {
        self.present(self.loadingAlert, animated: true)
    }

    private func dismissLoadingAlert() -> Promise<UIAlertController> {
        Promise<UIAlertController> { fulfill, _ in
            self.loadingAlert.dismiss(animated: true) {
                fulfill(self.loadingAlert)
            }
        }
    }

}
