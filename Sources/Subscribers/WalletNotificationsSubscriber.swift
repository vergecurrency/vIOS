//
//  WalletNotificationsSubscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 30/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit

class WalletNotificationsSubscriber: Subscriber {
    private let walletClient: WalletClientProtocol

    init(walletClient: WalletClientProtocol) {
        self.walletClient = walletClient
        super.init()
    }

    @objc func checkTransactionProposalError(notification: Notification) {
        guard let walletNotificationView = WalletNotificationView.shared else {
            return
        }

        self.walletClient.getTxProposals { proposals, error in
            if let error = error {
                let alert = UIAlertController.createUnexpectedErrorAlert(error: error)

                walletNotificationView.parentContainerViewController()?.present(alert, animated: true)

                return
            }

            if proposals.isEmpty {
                return
            }

            self.showTransactionProposalError(notification: Notification(name: notification.name, object: proposals))
        }
    }

    @objc func showTransactionProposalError(notification: Notification) {
        guard let walletNotificationView = WalletNotificationView.shared else {
            return
        }

        guard let proposals = notification.object as? [Vws.TxProposalResponse] else {
            return
        }

        walletNotificationView.warning(
            title: "wallet.notification.txpTitle".localized,
            message: String(format: "wallet.notification.txpMessage".localized, proposals.count)
        ) {
            let controller = UIStoryboard.createFromStoryboardWithNavigationController(
                name: "Settings",
                type: TransactionProposalsTableViewController.self
            )

            walletNotificationView.parentContainerViewController()?.present(controller, animated: true)
        }
    }

    @objc func removeTransactionProposalError(notification: Notification) {
        guard let walletNotificationView = WalletNotificationView.shared else {
            return
        }

        walletNotificationView.hide()
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        [
            .didLoadWalletViewController: #selector(checkTransactionProposalError(notification:)),
            .didFindTransactionProposals: #selector(showTransactionProposalError(notification:)),
            .didAbortTransactionWithError: #selector(checkTransactionProposalError(notification:)),
            .didResolveTransactionProposals: #selector(removeTransactionProposalError(notification:))
        ]
    }
}
