//
//  AddressesTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class AddressesTableViewController: EdgedTableViewController {

    var credentials: Credentials!

    var addresses: [AddressInfo] = []
    var balanceAddresses: [AddressBalance] = []

    var hasAddresses: Bool {
        return addresses.count > 0
    }

    var hasBalances: Bool {
        return balanceAddresses.count > 0
    }

    var balanceAddressesSection: Int {
        return hasAddresses ? 1 : 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl?.addTarget(
            self,
            action: #selector(AddressesTableViewController.loadAddress),
            for: .valueChanged
        )

        credentials = Credentials.shared

        loadAddress()
    }

    @objc func loadAddress() {
        refreshControl?.beginRefreshing()

        var options = WalletAddressesOptions()
        options.limit = 25
        options.reverse = true

        WalletClient.shared.getMainAddresses(options: options) { addresses in
            self.addresses = addresses.filter { addressInfo in
                return TransactionManager.shared.all(byAddress: addressInfo.address).count == 0
            }

            self.loadBalances()
        }
    }

    func loadBalances() {
        WalletClient.shared.getBalance { error, balanceInfo in
            guard let balanceInfo = balanceInfo else {
                self.balanceAddresses = []
                return
            }

            self.balanceAddresses = balanceInfo.byAddress

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return [
            hasAddresses,
            hasBalances
        ].filter { a in
            return a
        }.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == balanceAddressesSection ? balanceAddresses.count : addresses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case balanceAddressesSection:
            return balanceCell(tableView, cellForRowAt: indexPath)
        default:
            return addressCell(tableView, cellForRowAt: indexPath)
        }
    }

    func addressCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let address = addresses[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addresses") else {
            return UITableViewCell()
        }

        cell.textLabel?.text = address.address
        cell.detailTextLabel?.text = "xpub\(address.path.replacingOccurrences(of: "m", with: "")) \(address.createdOnDate.string)"

        cell.addTapGestureRecognizer(taps: 2) {
            UIPasteboard.general.string = address.address
            NotificationManager.shared.showMessage("Address copied!", duration: 3)
        }

        return cell
    }

    func balanceCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let balanceAddress = balanceAddresses[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addresses") else {
            return UITableViewCell()
        }

        cell.accessoryType = .detailButton
        cell.textLabel?.text = balanceAddress.address
        cell.detailTextLabel?.text = NSNumber(
            value: Double(balanceAddress.amount) / Constants.satoshiDivider
        ).toXvgCurrency()

        cell.addTapGestureRecognizer(taps: 2) {
            UIPasteboard.general.string = balanceAddress.address
            NotificationManager.shared.showMessage("Address copied!", duration: 3)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case balanceAddressesSection:
            return hasBalances ? "Addresses with balance" : ""
        default:
            return hasAddresses ? "Unused addresses" : ""
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let balanceAddress = balanceAddresses[indexPath.row]
        let privateKey = try? credentials.privateKeyBy(
            path: balanceAddress.path!,
            privateKey: credentials.bip44PrivateKey
        )
        let publicKey = privateKey?.publicKey()

        let sheet = UIAlertController(
            title: "Address options",
            message: "What information would you like to copy to the clipboard?",
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Address", style: .default) { action in
            self.toPasteboard(message: "Address copied!", value: balanceAddress.address)
        })

        sheet.addAction(UIAlertAction(title: "Balance", style: .default) { action in
            self.toPasteboard(message: "Balance copied!", value: "\(Double(balanceAddress.amount) / Constants.satoshiDivider)")
        })

        sheet.addAction(UIAlertAction(title: "Public key", style: .default) { action in
            self.toPasteboard(message: "Public key copied!", value: publicKey?.description)
        })

        sheet.addAction(UIAlertAction(title: "Private key", style: .destructive) { action in
            let unlockView = PinUnlockViewController.createFromStoryBoard()
            unlockView.cancelable = true
            unlockView.completion = { aunthenticated in
                unlockView.dismiss(animated: true)

                if !aunthenticated {
                    return
                }

                self.toPasteboard(message: "Private key copied!", value: privateKey?.toWIF())
            }

            self.present(unlockView, animated: true)
        })

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(sheet, animated: true)
    }

    func toPasteboard(message: String, value: String?) {
        UIPasteboard.general.string = value
        NotificationManager.shared.showMessage(message, duration: 3)
    }

    @IBAction func scanAddresses(_ sender: UIButton) {
        WalletClient.shared.scanAddresses()

        sender.isEnabled = false
        sender.backgroundColor = UIColor.vergeGrey()

        let alert = UIAlertController(
            title: "Scanning Addresses",
            message: "Scanning addresses for balance. This might take some time to complete.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .default))

        present(alert, animated: true)
    }
}
