//
//  PaperWalletTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class PaperWalletTableViewController: EdgedTableViewController {

    var cells: [UITableViewCell] = []
    var privateKeyCell: UITableViewCell!
    var amountCell: UITableViewCell!

    override func loadView() {
        super.loadView()

        self.tableView.backgroundColor = ThemeManager.shared.backgroundGrey()

        self.privateKeyCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        self.privateKeyCell.textLabel?.text = "Private key"
        self.privateKeyCell.detailTextLabel?.text = "ajsj0d9a90dja09aj"
        self.privateKeyCell.updateColors()
        self.privateKeyCell.updateFonts()

        self.amountCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        self.amountCell.textLabel?.text = "Amount"
        self.amountCell.detailTextLabel?.text = "480.948,54445 XVG"
        self.amountCell.updateColors()
        self.amountCell.updateFonts()

        self.cells = [
            self.privateKeyCell,
            self.amountCell
        ]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.cells[indexPath.row]
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
}

extension PaperWalletTableViewController: WalletSweepingScannerViewDelegate {
    func didScanValue(scannedValue: String) {
        self.privateKeyCell.detailTextLabel?.text = scannedValue
    }
}
