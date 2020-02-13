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

class ElectrumMnemonicTableViewController: UITableViewController {

    var sweeperHelper: SweeperHelperProtocol!
    var sections: [TableSection] = []
    var loadingAlert: UIAlertController = UIAlertController.loadingAlert()

    override func loadView() {
        super.loadView()

        self.tableView.updateColors()

        let inputCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        inputCell.textLabel?.text = "sweeping.privateKey.cell.fillInLabel".localized
        inputCell.imageView?.image = UIImage(named: "Quill")
        inputCell.updateColors()
        inputCell.updateFonts()

        self.sections.append(TableSection(
            header: "sweeping.privateKey.header.title".localized,
            footer: "sweeping.privateKey.footer.title".localized,
            items: [inputCell]
        ))

        self.tableView.tableHeaderView = TableHeaderView(
            title: "sweeping.privateKey.titleLabel".localized,
            image: UIImage(named: "PrivateKeySweepingPlaceholder")!
        )
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].items[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let alert = UIAlertController(
                title: "sweeping.privateKey.alert.title".localized,
                message: "sweeping.privateKey.alert.message".localized,
                preferredStyle: .alert
            )

            alert.addTextField { field in
                field.placeholder = "sweeping.privateKey.alert.placeholder".localized
            }

            alert.addAction(UIAlertAction(title: "settings.sweeping.sweep".localized, style: .default) { _ in
                guard let privateKey = alert.textFields?.first?.text else {
                    return
                }
                self.didScanValue(scannedValue: privateKey)
            })

            alert.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))

            self.present(alert, animated: true)
        default:
            tableView.deselectRow(at: indexPath, animated: false)
            print("Not implemented")
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sections[section].footer
    }

    private func sweep(balances: [String: BNBalance], toAddress address: String) {
        do {
            let filteredBalances = balances.filter { balance in
                return balance.value.confirmed > 0
            }

            try self.sweeperHelper.sweep(
                balance: filteredBalances.first!.value,
                destinationAddress: address,
                privateKeyWIF: filteredBalances.first!.key
            ) { error, txid in
                guard let txid = txid else {
                    return error != nil ? self.showUnexpectedErrorAlert(error: error!) : self.showNoTxIDAlert()
                }

                let alert = UIAlertController(
                    title: "sweeping.privateKey.swept.title".localized,
                    message: "sweeping.privateKey.swept.description".localized + ":\n\n" + txid,
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "defaults.done".localized, style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })

                self.present(alert, animated: true)
            }
        } catch PrivateKeyError.invalidFormat {
            self.showInvalidPrivateKeyAlert()
        } catch {
            self.showUnexpectedErrorAlert(error: error)
        }
    }

    private func prepareSweepingWithScannedValue(scannedValue: String) throws {
        let mnemonic = scannedValue.decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let salt = ("electrum" + "").decomposedStringWithCompatibilityMapping.data(using: .utf8)!
        let seed = _Key.deriveKey(mnemonic, salt: salt, iterations: 2048, keyLength: 64)

        let privateKey = HDPrivateKey(seed: seed, network: .mainnetXVG)

        let m0prv = try! privateKey.derived(at: 0)
        let m1prv = try! privateKey.derived(at: 1)

        var keys: [String] = []
        var addresses: [String] = []

        for i in 0..<20 {
            keys.append(try! m0prv.derived(at: UInt32(i)).privateKey().toWIF())
            addresses.append(try! m0prv.derived(at: UInt32(i)).privateKey().publicKey().toLegacy().description)
        }

        for i in 0..<6 {
            keys.append(try! m1prv.derived(at: UInt32(i)).privateKey().toWIF())
            addresses.append(try! m1prv.derived(at: UInt32(i)).privateKey().publicKey().toLegacy().description)
        }

        print(keys)
        print(addresses)

        let confirmSweepView = Bundle.main.loadNibNamed(
            "ConfirmSweepView",
            owner: self,
            options: nil
        )?.first as! ConfirmSweepView

        let alertController = confirmSweepView.makeActionSheet()
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0,
                height: 0
            )

            popoverController.permittedArrowDirections = []
        }

        self.loadingAlert.message = "Scanning balances 0/\(keys.count)"

        try self.loadBalances(keys: keys).then { balances in
            self.dismissLoadingAlert().then { _ in
                self.present(alertController, animated: true)
            }

            let amount = NSNumber(floatLiteral: Double(balances.reduce(0, { result, balance in
                return result + balance.value.confirmed
            })) / Constants.satoshiDivider)

            self.sweeperHelper.recipientAddress { _, address in
                guard let address = address else {
                    return
                }

                confirmSweepView.setup(toAddress: address, amount: amount)

                let sendAction = UIAlertAction(title: "settings.sweeping.sweep".localized, style: .default) { _ in
                    self.sweep(balances: balances, toAddress: address)
                }
                sendAction.setValue(UIImage(named: "Sweep"), forKey: "image")

                alertController.addAction(sendAction)
                alertController.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
            }
        }
    }

    private func loadBalances(keys: [String]) throws -> Promise<[String: BNBalance]> {
        var keysDone = 0
        var balances: [String: BNBalance] = [:]

        return Promise<[String: BNBalance]> { fulfill, _ in
            for key in keys {
                try self.sweeperHelper.balance(byPrivateKeyWIF: key) { _, balance in
                    keysDone += 1

                    self.loadingAlert.message = "Scanning balances \(keysDone)/\(keys.count)"

                    guard let balance = balance, balance.balance >= 0 else {
                        return self.showNotEnoughBalanceAlert()
                    }

                    balances[key] = balance

                    if keysDone == 26 {
                        fulfill(balances)
                    }
                }
            }
        }
    }

    private func showNotEnoughBalanceAlert() {
        self.dismissLoadingAlert().then { _ in
            self.present(UIAlertController.createNotEnoughBalanceAlert(), animated: true)
        }
    }

    private func showInvalidPrivateKeyAlert() {
        self.dismissLoadingAlert().then { _ in
            self.present(UIAlertController.createInvalidPrivateKeyAlert(), animated: true)
        }
    }

    private func showNoTxIDAlert() {
        self.dismissLoadingAlert().then { _ in
            self.present(UIAlertController.createNoTxIDAlert(), animated: true)
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
        return Promise<UIAlertController> { fulfill, _ in
            self.loadingAlert.dismiss(animated: true) {
                fulfill(self.loadingAlert)
            }
        }
    }

}

extension ElectrumMnemonicTableViewController: WalletSweepingScannerViewDelegate {
    func didScanValue(scannedValue: String) {
        self.showLoadingAlert()

        do {
            try self.prepareSweepingWithScannedValue(scannedValue: scannedValue)
        } catch PrivateKeyError.invalidFormat {
            self.showInvalidPrivateKeyAlert()
        } catch {
            self.showUnexpectedErrorAlert(error: error)
        }
    }
}
