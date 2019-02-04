//
// Created by Swen van Zanten on 26/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class DonateTableViewController: EdgedTableViewController {

    @IBOutlet weak var donationAddressTableViewCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        donationAddressTableViewCell.detailTextLabel?.text = Constants.donationXvgAddress
    }

    @IBAction func donate(_ sender: Any) {
        // Create a send transaction.
        let sendTransaction = TransactionFactory()
        sendTransaction.address = Constants.donationXvgAddress
        sendTransaction.amount = NSNumber(value: 0)

        // Notify the system to show the send view.
        NotificationCenter.default.post(name: .demandSendView, object: sendTransaction)
    }

}
