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

        guard let proposals = notification.object as? [TxProposalResponse] else {
            return
        }

        walletNotificationView.warning(
            title: "Inaccurate Balance",
            message: "\(proposals.count) Transaction proposal found"
        ) {
            let controller = UIStoryboard.createFromStoryboard(
                name: "Settings",
                type: TransactionProposalsTableViewController.self
            )
            let navigationController = UINavigationController(rootViewController: controller)
            let closeButton = UIBarButtonItem(image: UIImage(named: "Close"), style: .plain) { _ in
                controller.dismiss(animated: true)
            }

            controller.navigationItem.setLeftBarButtonItems([closeButton], animated: false)

            walletNotificationView.parentContainerViewController()?.present(navigationController, animated: true)
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
