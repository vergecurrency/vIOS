//
//  PaperWalletTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class PaperWalletTableViewController: EdgedTableViewController {

    var sweeperHelper: SweeperHelperProtocol!

    var sections: [[UITableViewCell]] = []
    var startingCells: [UITableViewCell] = []
    var detailCells: [UITableViewCell] = []
    var privateKeyCell: UITableViewCell!
    var amountCell: UITableViewCell!
    var recipientAddressCell: UITableViewCell!

    override func loadView() {
        super.loadView()

        self.tableView.backgroundColor = ThemeManager.shared.backgroundGrey()

        self.privateKeyCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        self.privateKeyCell.textLabel?.text = "Private key"
        self.privateKeyCell.detailTextLabel?.text = "Scan wallet private key..."
        self.privateKeyCell.imageView?.image = UIImage(named: "QRcode")
        self.privateKeyCell.updateColors()
        self.privateKeyCell.detailTextLabel?.textColor = ThemeManager.shared.vergeGrey()
        self.privateKeyCell.textLabel?.font = UIFont.avenir(size: 14).demiBold()
        self.privateKeyCell.detailTextLabel?.font = UIFont.avenir(size: 17)

        self.amountCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        self.amountCell.textLabel?.text = "Amount"
        self.amountCell.updateColors()
        self.amountCell.textLabel?.font = UIFont.avenir(size: 14).demiBold()
        self.amountCell.detailTextLabel?.font = UIFont.avenir(size: 24)

        self.recipientAddressCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        self.recipientAddressCell.textLabel?.text = "Your Recipient Address"
        self.recipientAddressCell.updateColors()
        self.recipientAddressCell.textLabel?.font = UIFont.avenir(size: 14).demiBold()
        self.recipientAddressCell.detailTextLabel?.font = UIFont.avenir(size: 17)

        self.startingCells.append(self.privateKeyCell)
        self.sections.append(self.startingCells)

        self.tableView.tableHeaderView = TableHeaderView(
            title: "Lets sweep a private key wallet",
            image: UIImage(named: "PrivateKeySweepingPlaceholder")!
        )
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section][indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let walletSweepingScannerViewController = WalletSweepingScannerViewController()
            walletSweepingScannerViewController.delegate = self

            self.present(walletSweepingScannerViewController, animated: true)
        default:
            tableView.deselectRow(at: indexPath, animated: false)
            print("Not implemented")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Sweeping details"
        default:
            return "Sweeping from"
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Import the wallets available XVG amount to your iOS wallet."
        default:
            return "Scan a valid XVG private key QR code from a paper wallet, card wallet or any other private key based wallet."
        }
    }

    private func addSendButton() {
        let sendButton = RoundedButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = ThemeManager.shared.primaryLight()

        let footerView = UIView()
        footerView.frame.size.height = 50
        footerView.addSubview(sendButton)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.topAnchor.constraint(equalTo: footerView.topAnchor)
        sendButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor)
        sendButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor)
        sendButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor)

        self.tableView.tableFooterView = footerView
    }
}

extension PaperWalletTableViewController: WalletSweepingScannerViewDelegate {
    func didScanValue(scannedValue: String) {
        self.privateKeyCell.detailTextLabel?.text = scannedValue
        self.privateKeyCell.detailTextLabel?.textColor = ThemeManager.shared.primaryLight()

        self.sweeperHelper.balance(byPrivateKeyWIF: scannedValue) { _, balance in
            guard let balance = balance else { return }

            let amount = NSNumber(floatLiteral: Double(balance.balance) / Constants.satoshiDivider).toXvgCurrency()
            self.amountCell.detailTextLabel?.text = amount

            self.sweeperHelper.recipientAddress { _, address in
                self.recipientAddressCell.detailTextLabel?.text = address

                self.detailCells.append(self.amountCell)
                self.detailCells.append(self.recipientAddressCell)
                self.sections.append(self.detailCells)

                self.addSendButton()

                self.tableView.reloadData()
            }
        }
    }
}
