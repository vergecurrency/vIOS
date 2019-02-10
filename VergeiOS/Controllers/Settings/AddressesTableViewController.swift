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
        options.limit = 25
        options.reverse = true

        WalletClient.shared.getMainAddresses(options: options) { addresses in
            self.addresses = addresses.filter { addressInfo in
                return TransactionManager.shared.all(byAddress: addressInfo.address).count == 0
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let address = addresses[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "addresses") {
            cell.textLabel?.text = address.address
            cell.detailTextLabel?.text = "xpub\(address.path.replacingOccurrences(of: "m", with: "")) \(address.createdOnDate.string)"
            
            cell.addTapGestureRecognizer(taps: 2) {
                UIPasteboard.general.string = address.address
                NotificationManager.shared.showMessage("Address copied!", duration: 3)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Unused addresses"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
