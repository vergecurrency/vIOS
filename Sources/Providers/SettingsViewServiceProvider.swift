//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import UIKit

class SettingsViewServiceProvider: ServiceProvider {

    override func register() {
        var tableViewStyle: UITableView.Style = .grouped
        if #available(iOS 13.0, *) {
            tableViewStyle = .insetGrouped
        }

        container.storyboardInitCompleted (SettingsTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.credentials = r.resolve(Credentials.self)
            c.walletClient = r.resolve(WalletClientProtocol.self)
            c.walletManager = r.resolve(WalletManagerProtocol.self)
            c.walletTicker = r.resolve(WalletTicker.self)
            c.fiatRateTicker = r.resolve(FiatRateTicker.self)
            c.transactionManager = r.resolve(TransactionManager.self)
        }

        container.storyboardInitCompleted (TorConnectionTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.torClient = r.resolve(TorClient.self)
            c.httpSession = r.resolve(HttpSessionProtocol.self)
        }

        container.storyboardInitCompleted (CurrencyTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (LocalAuthTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }
        
        container.storyboardInitCompleted (ServiceUrlTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.walletClient = r.resolve(WalletClientProtocol.self)
            c.walletManager = r.resolve(WalletManagerProtocol.self)
        }

        container.register(ElectrumXServersTableViewController.self) { r in
            let controller = ElectrumXServersTableViewController(style: tableViewStyle)
            controller.applicationRepository = r.resolve(ApplicationRepository.self)
            controller.electrumXClient = ElectrumXClient(
                applicationRepository: controller.applicationRepository,
                httpSession: r.resolve(HttpSessionProtocol.self),
                hiddenClient: r.resolve(TorClient.self)
            )

            return controller
        }

        container.storyboardInitCompleted (TransactionProposalsTableViewController.self) { r, c in
            c.walletClient = r.resolve(WalletClientProtocol.self)
            c.txTransponder = r.resolve(TxTransponderProtocol.self)
        }

        container.storyboardInitCompleted (ThemeTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (WalletSweepingTableViewController.self) { _, c in
            c.container = self.container
        }

        container.register (PaperWalletTableViewController.self) { r in
            let controller = PaperWalletTableViewController(style: tableViewStyle)
            controller.sweeperHelper = r.resolve(SweeperHelperProtocol.self)

            return controller
        }

        container.register (ElectrumMnemonicTableViewController.self) { r in
            let controller = ElectrumMnemonicTableViewController(style: tableViewStyle)
            controller.sweeperHelper = r.resolve(SweeperHelperProtocol.self)

            return controller
        }
    }

}
