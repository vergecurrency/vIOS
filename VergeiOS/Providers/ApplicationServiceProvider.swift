//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class ApplicationServiceProvider: ServiceProvider {

    override func boot() {
        self.bootWatchSyncManager()

        TorStatusIndicator.shared.initialize()
        NotificationManager.shared.initialize()
        IQKeyboardManager.shared.enable = true

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        ThemeManager.shared.initialize(withWindow: appDelegate.window ?? UIWindow())
    }

    override func register() {
        container.register(ApplicationRepository.self) { r in
            return ApplicationRepository()
        }.inObjectScope(.container)

        container.register(ShortcutsManager.self) { r in
            let applicationRepository = r.resolve(ApplicationRepository.self)!

            return ShortcutsManager(hasWallet: applicationRepository.setup)
        }.inObjectScope(.container)

        container.storyboardInitCompleted (MainTabBarController.self) { r, c in
            c.shortcutsManager = r.resolve(ShortcutsManager.self)
        }
    }

    private func bootWatchSyncManager() {
        let walletClient = container.resolve(WalletClient.self)!

        WatchSyncManager(walletClient: walletClient).startSession()
    }

}
