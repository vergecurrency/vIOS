//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class SettingsViewServiceProvider: ServiceProvider {

    override func register() {
        container.storyboardInitCompleted (SettingsTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (TorConnectionTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.torClient = r.resolve(TorClient.self)
        }

        container.storyboardInitCompleted (CurrencyTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (LanguageTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (LocalAuthTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (ServiceUrlTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.walletTicker = r.resolve(WalletTicker.self)
            c.walletClient = r.resolve(WalletClient.self)
        }

        container.storyboardInitCompleted (DisconnectWalletViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.transactionManager = r.resolve(TransactionManager.self)
            c.walletTicker = r.resolve(WalletTicker.self)
            c.fiatRateTicker = r.resolve(FiatRateTicker.self)
            c.torClient = r.resolve(TorClient.self)
        }

        container.storyboardInitCompleted (TransactionProposalsTableViewController.self) { r, c in
            c.walletClient = r.resolve(WalletClient.self)
        }

        container.storyboardInitCompleted (ThemeTableViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (WalletSweepingTableViewController.self) { r, c in
            c.container = self.container
        }

        container.register (PaperWalletTableViewController.self) { r in
            let controller = PaperWalletTableViewController(style: .grouped)
            controller.sweeperHelper = r.resolve(SweeperHelperProtocol.self)

            return controller
        }
    }

}
