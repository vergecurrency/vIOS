//
// Created by Swen van Zanten on 2019-02-14.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import UIKit

class TransactionProposalsTableViewController: EdgedTableViewController {

    var walletClient: WalletClientProtocol!
    var txTransponder: TxTransponderProtocol!
    var proposals: [Vws.TxProposalResponse] = []

    var initialLoaded: Bool = false
    var hasProposals: Bool {
        return self.proposals.count > 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl?.addTarget(
            self,
            action: #selector(TransactionProposalsTableViewController.loadProposals),
            for: .valueChanged
        )

        self.loadProposals()
    }

    @objc func loadProposals() {
        self.refreshControl?.beginRefreshing()

        self.walletClient.getTxProposals { proposals, error in
            self.initialLoaded = true

            if let error = error {
                return self.showLoadingError(error: error)
            }

            if proposals.isEmpty {
                NotificationCenter.default.post(name: .didResolveTransactionProposals, object: nil)
            } else {
                NotificationCenter.default.post(name: .didFindTransactionProposals, object: proposals)
            }

            self.proposals = proposals

            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hasProposals ? self.proposals.count : (self.initialLoaded ? 1 : 0)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.hasProposals ? "settings.wallet.cell.transactionsLabel".localized : ""
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !self.hasProposals {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.themeable = true
            cell.textLabel?.text = "settings.transactions.noProposals".localized
            cell.textLabel?.textColor = ThemeManager.shared.vergeGrey()
            cell.selectionStyle = .none
            cell.updateColors()

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "proposals") else {
            return UITableViewCell()
        }

        let proposal = self.proposals[indexPath.row]
        let amount = NSNumber(value: Double(proposal.amount) / Constants.satoshiDivider).toXvgCurrency()

        cell.textLabel?.text = proposal.id
        cell.detailTextLabel?.text = "[\(proposal.status)] - \(amount)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.proposals.isEmpty {
            return
        }

        let proposal = self.proposals[indexPath.row]

        let sheet = UIAlertController(
            title: "settings.transactions.resolveProposal".localized,
            message: "settings.transactions.resolveOptions".localized,
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "settings.transactions.retrySending".localized, style: .default) { _ in
            self.txTransponder.send(txp: proposal) { _, errorResponse, error in
                if let error = error {
                    return self.showLoadingError(error: error)
                }

                if let errorResponse = errorResponse?.error as? Error {
                    return self.showLoadingError(error: errorResponse)
                }

                self.showTxSent()
                self.loadProposals()
            }
        })

        sheet.addAction(UIAlertAction(
            title: "settings.transactions.destroyTransaction".localized,
            style: .destructive) { _ in
                self.refreshControl?.beginRefreshing()

                self.walletClient.deleteTxProposal(txp: proposal) { _ in
                    self.loadProposals()
                }
            }
        )

        sheet.addAction(UIAlertAction(title: "defaults.cancel".localized, style: .cancel))
        sheet.centerPopoverController(to: self.view)

        self.present(sheet, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    private func showTxSent() {
        let alert = UIAlertController(
            title: "Transaction sent",
            message: "The previously failed proposal successfully sent!",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "defaults.done".localized, style: .default))

        self.present(alert, animated: true)
    }

    private func showLoadingError(error: Error) {
        ErrorView.showError(error: error, bind: self.view) {
            self.loadProposals()
        }
    }
}
