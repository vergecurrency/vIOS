//
//  PaperWalletTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit
import BitcoinKit

class PaperWalletTableViewController: EdgedTableViewController {

    var sweeperHelper: SweeperHelperProtocol!
    var sections: [TableSection] = []

    override func loadView() {
        super.loadView()

        self.tableView.backgroundColor = ThemeManager.shared.backgroundGrey()

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

    private func sweep(balance: BNBalance, toAddress address: String, key: String) {
        do {
            try self.sweeperHelper.sweep(
                balance: balance,
                destinationAddress: address,
                privateKeyWIF: key
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
        try self.sweeperHelper.balance(byPrivateKeyWIF: scannedValue) { _, balance in
            guard let balance = balance, balance.balance > 0 else {
                return self.showNotEnoughBalanceAlert()
            }

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

            self.present(alertController, animated: true)

            let amount = NSNumber(floatLiteral: Double(balance.balance) / Constants.satoshiDivider)

            self.sweeperHelper.recipientAddress { _, address in
                guard let address = address else {
                    return
                }

                confirmSweepView.setup(toAddress: address, amount: amount)

                let sendAction = UIAlertAction(title: "settings.sweeping.sweep".localized, style: .default) { _ in
                    self.sweep(balance: balance, toAddress: address, key: scannedValue)
                }
                sendAction.setValue(UIImage(named: "Sweep"), forKey: "image")

                alertController.addAction(sendAction)
                alertController.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
            }
        }
    }

    private func showNotEnoughBalanceAlert() {
        let alertController = UIAlertController(
            title: "Not Enough Balance",
            message: "Your scanned private key doesn't seem to have enough balance.",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        self.present(alertController, animated: true)
    }

    private func showInvalidPrivateKeyAlert() {
        let alertController = UIAlertController(
            title: "Invalid Private Key",
            message: "You've provided an invalid private key because it couldn't be resolved. "
                + "Please make sure you've scanned of filled in the correct key.",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        self.present(alertController, animated: true)
    }

    private func showNoTxIDAlert() {
        let alertController = UIAlertController(
            title: "No TXID returned",
            message: """
                     There was no TXID returned. So we can't be sure the wallet was swept. 
                     You quickly check if the wallet is swept you can try sweeping it again.
                     """,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        self.present(alertController, animated: true)
    }

    private func showUnexpectedErrorAlert(error: Error) {
        let alertController = UIAlertController(
            title: "Unexpected Error",
            message: "Unexpected error thrown with message: \(error.localizedDescription)",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "defaults.ok".localized, style: .default))

        self.present(alertController, animated: true)
    }
}

extension PaperWalletTableViewController: WalletSweepingScannerViewDelegate {
    func didScanValue(scannedValue: String) {
        do {
            try self.prepareSweepingWithScannedValue(scannedValue: scannedValue)
        } catch PrivateKeyError.invalidFormat {
            self.showInvalidPrivateKeyAlert()
        } catch {
            self.showUnexpectedErrorAlert(error: error)
        }
    }
}
