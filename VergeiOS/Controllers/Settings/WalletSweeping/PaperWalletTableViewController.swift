//
//  PaperWalletTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit
import BitcoinKit
import Promises

class PaperWalletTableViewController: EdgedTableViewController {
    var sweeperHelper: SweeperHelperProtocol!
    var sections: [TableSection] = []
    var loadingAlert: UIAlertController = UIAlertController.loadingAlert()

    override func loadView() {
        super.loadView()

        self.tableView.updateColors()

        let scanCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        scanCell.textLabel?.text = "sweeping.privateKey.cell.scanLabel".localized
        scanCell.imageView?.image = UIImage(named: "QRcode")
        scanCell.updateColors()
        scanCell.updateFonts()

        let inputCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        inputCell.textLabel?.text = "sweeping.privateKey.cell.fillInLabel".localized
        inputCell.imageView?.image = UIImage(named: "Quill")
        inputCell.updateColors()
        inputCell.updateFonts()

        self.sections.append(TableSection(
            header: "sweeping.privateKey.header.title".localized,
            footer: "sweeping.privateKey.footer.title".localized,
            items: [scanCell, inputCell]
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
            let walletSweepingScannerViewController = WalletSweepingScannerViewController()
            walletSweepingScannerViewController.delegate = self

            self.present(walletSweepingScannerViewController, animated: true)
        case 1:
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

    private func sweep(balance: Bn.Balance, toAddress address: String, key: String) {
        do {
            let privateKey = try self.sweeperHelper.wifToPrivateKey(wif: key)

            self.sweeperHelper.sweep(
                keyBalances: [KeyBalance(privateKey: privateKey, balance: balance)],
                destinationAddress: address
            ).then { txid in
                let alert = UIAlertController(
                    title: "sweeping.privateKey.swept.title".localized,
                    message: "\("sweeping.privateKey.swept.description".localized):\n\n\(txid)",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "defaults.done".localized, style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })

                self.present(alert, animated: true)
            }.catch { error in
                self.showUnexpectedErrorAlert(error: error)
            }
        } catch PrivateKeyError.invalidFormat {
            self.showInvalidPrivateKeyAlert()
        } catch {
            self.showUnexpectedErrorAlert(error: error)
        }
    }

    private func prepareSweepingWithScannedValue(scannedValue: String) throws {
        let privateKey = try self.sweeperHelper.wifToPrivateKey(wif: scannedValue)

        let confirmSweepView = Bundle.main.loadNibNamed(
            "ConfirmSweepView",
            owner: self,
            options: nil
        )?.first as! ConfirmSweepView

        let alertController = confirmSweepView.makeActionSheet()
        alertController.centerPopoverController(to: self.view)

        var savedBalance: Bn.Balance?
        var savedAmount: NSNumber?

        self.sweeperHelper
            .balance(privateKey: privateKey)
            .then { balance in
                let amount = NSNumber(value: Double(balance.balance) / Constants.satoshiDivider)

                if amount == 0 {
                    throw SweeperHelper.Error.notEnoughBalance
                }

                self.dismissLoadingAlert().then { _ in
                    self.present(alertController, animated: true)
                }
                savedBalance = balance
                savedAmount = amount
            }
            .then { _ in
                return self.sweeperHelper.recipientAddress()
            }
            .then { address in
                confirmSweepView.setup(toAddress: address, amount: savedAmount!)

                let sendAction = UIAlertAction(title: "settings.sweeping.sweep".localized, style: .default) { _ in
                    self.sweep(balance: savedBalance!, toAddress: address, key: scannedValue)
                }
                sendAction.setValue(UIImage(named: "Sweep"), forKey: "image")

                alertController.addAction(sendAction)
                alertController.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
            }
            .catch { error in
                switch error {
                case SweeperHelper.Error.notEnoughBalance:
                    self.showNotEnoughBalanceAlert()
                case BitcoreNodeClient.Error.txNotAccepted:
                    self.showTxNotAcceptedAlert()
                default:
                    self.showUnexpectedErrorAlert(error: error)
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

    private func showTxNotAcceptedAlert() {
        self.dismissLoadingAlert().then { _ in
            self.present(UIAlertController.createTxNotAcceptedAlert(), animated: true)
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

extension PaperWalletTableViewController: WalletSweepingScannerViewDelegate {
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
