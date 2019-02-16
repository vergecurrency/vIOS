//
// Created by Swen van Zanten on 2019-02-14.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import UIKit

class TransactionProposalsTableViewController: UITableViewController {

    var proposals: [TxProposalResponse] = []

    var hasProposals: Bool {
        return proposals.count > 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl?.addTarget(
            self,
            action: #selector(TransactionProposalsTableViewController.loadProposals),
            for: .valueChanged
        )

        loadProposals()
    }

    @objc func loadProposals() {
        refreshControl?.beginRefreshing()

        WalletClient.shared.getTxProposals { proposals, error in
            self.proposals = proposals

            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasProposals ? proposals.count : 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return hasProposals ? "Remove a proposal" : ""
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !hasProposals {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "No proposals"
            cell.textLabel?.textColor = .vergeGrey()
            cell.selectionStyle = .none

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "proposals") else {
            return UITableViewCell()
        }

        let proposal = proposals[indexPath.row]
        let amount = NSNumber(value: Double(proposal.amount) / Constants.satoshiDivider).toXvgCurrency()

        cell.textLabel?.text = proposal.id
        cell.detailTextLabel?.text = "[\(proposal.status)] - \(amount)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if proposals.isEmpty {
            return
        }

        let proposal = proposals[indexPath.row]
        
        let sheet = UIAlertController(
            title: "Remove Proposal",
            message: "Release the XVG of this transaction proposal.",
            preferredStyle: .alert
        )
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Remove", style: .destructive) { action in
            self.refreshControl?.beginRefreshing()

            WalletClient.shared.deleteTxProposal(txp: proposal) { error in
                self.loadProposals()
            }
        })

        present(sheet, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }

}
