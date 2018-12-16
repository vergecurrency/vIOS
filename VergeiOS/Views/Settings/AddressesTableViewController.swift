//
//  AddressesTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class AddressesTableViewController: EdgedTableViewController {

    var addresses: [AddressInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        var options = WalletAddressesOptions()
        options.limit = 15
        options.reverse = true

        WalletClient.shared.getMainAddresses(options: options) { addresses in
            DispatchQueue.main.async {
                self.addresses = addresses
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let address = addresses[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "addresses") as! UITableViewCell
        cell.textLabel?.text = address.address
        cell.detailTextLabel?.text = "xpub\(address.path.replacingOccurrences(of: "m", with: "")) \(address.createdOnDate.string)"

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Last \(addresses.count) unused addresses"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = addresses[indexPath.row].address

        UIPasteboard.general.string = address
        NotificationManager.shared.showMessage("Address copied!", duration: 3)

        tableView.deselectRow(at: indexPath, animated: true)
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
