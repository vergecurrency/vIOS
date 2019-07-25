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
        self.recipientAddressCell.textLabel?.text = "Recipient Address"
        self.recipientAddressCell.detailTextLabel?.text = "Set a recipient address"
        self.recipientAddressCell.updateColors()
        self.recipientAddressCell.detailTextLabel?.textColor = ThemeManager.shared.vergeGrey()
        self.recipientAddressCell.textLabel?.font = UIFont.avenir(size: 14).demiBold()
        self.recipientAddressCell.detailTextLabel?.font = UIFont.avenir(size: 17)

        self.startingCells.append(self.privateKeyCell)
        self.sections.append(self.startingCells)

        self.tableView.tableHeaderView = TableHeaderView(
            title: "Let's sweep a private key wallet",
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
}

extension PaperWalletTableViewController: WalletSweepingScannerViewDelegate {
    func didScanValue(scannedValue: String) {
        self.privateKeyCell.detailTextLabel?.text = scannedValue
        self.privateKeyCell.detailTextLabel?.textColor = ThemeManager.shared.primaryLight()

        self.sweeperHelper.balance(byPrivateKeyWIF: scannedValue) { _, balance in
            guard let balance = balance else { return }

            let amount = NSNumber(floatLiteral: Double(balance.balance) / Constants.satoshiDivider).toXvgCurrency()
            self.amountCell.detailTextLabel?.text = amount

            self.detailCells.append(self.amountCell)
            self.detailCells.append(self.recipientAddressCell)
            self.sections.append(self.detailCells)

            self.tableView.reloadData()
        }
    }
}
