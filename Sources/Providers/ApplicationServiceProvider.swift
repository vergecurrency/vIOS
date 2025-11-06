//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import Swinject
import Logging

class ApplicationServiceProvider: ServiceProvider {

    override func boot() {
        TorStatusIndicator.shared.initialize()
        NotificationBar.shared.initialize()

        IQKeyboardManager.shared.enable = true

        if let window = (UIApplication.shared.delegate as! AppDelegate).window {
            window.tintColor = ThemeManager.shared.primaryLight()
        }

        self.bootWatchSyncManager()
    }

    override func register() {

        container.register(SubscriberProtocol.self, name: "WalletSubscriber") { r in
            WalletSubscriber(
                walletTicker: r.resolve(WalletTicker.self)!,
                walletClient: r.resolve(WalletClientProtocol.self)!,
                fiatRateTicker: r.resolve(FiatRateTicker.self)!,
                shortcutsManager: r.resolve(ShortcutsManager.self)!,
                applicationRepository: r.resolve(ApplicationRepository.self)!,
                transactionManager: r.resolve(TransactionManager.self)!
            )
        }
        self.container.register(ApplicationRepository.self) { _ in
            return ApplicationRepository()
        }.inObjectScope(.container)

        self.container.register(ShortcutsManager.self) { r in
            let applicationRepository = r.resolve(ApplicationRepository.self)!

            return ShortcutsManager(applicationRepository: applicationRepository)
        }.inObjectScope(.container)

        self.container.storyboardInitCompleted (MainTabBarController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.shortcutsManager = r.resolve(ShortcutsManager.self)
        }

        self.container.register(WatchSyncManager.self) { r in
            let walletClient = r.resolve(WalletClientProtocol.self)!

            return WatchSyncManager(walletClient: walletClient)
        }.inObjectScope(.container)

        self.container.register(Logger.self) { r in
            var log = Logger(label: "org.verge.wallet.main")
            log.logLevel = .info

            Container.loggingFunction = { message in
                log.debug(Logger.Message(stringLiteral: message))
            }

            return log
        }
    }

    private func bootWatchSyncManager() {
        self.container.resolve(WatchSyncManager.self)?.startSession()
    }

}
extension Container {
    static var loggingFunction: ((String) -> Void)?

    func log(_ message: String) {
        Self.loggingFunction?(message)
    }
}
