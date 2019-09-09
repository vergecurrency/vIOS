//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class ApplicationServiceProvider: ServiceProvider {

    override func boot() {
        IQKeyboardManager.shared.enable = true

        self.bootWatchSyncManager()
    }

    override func register() {
        container.register(ApplicationRepository.self) { _ in
            return ApplicationRepository()
        }.inObjectScope(.container)

        container.register(ShortcutsManager.self) { r in
            let applicationRepository = r.resolve(ApplicationRepository.self)!

            return ShortcutsManager(applicationRepository: applicationRepository)
        }.inObjectScope(.container)

//        container.storyboardInitCompleted (MainTabBarController.self) { r, c in
//            c.applicationRepository = r.resolve(ApplicationRepository.self)
//            c.shortcutsManager = r.resolve(ShortcutsManager.self)
//        }

        container.register(WatchSyncManager.self) { r in
            let walletClient = r.resolve(WalletClient.self)!

            return WatchSyncManager(walletClient: walletClient)
        }.inObjectScope(.container)
    }

    private func bootWatchSyncManager() {
        container.resolve(WatchSyncManager.self)?.startSession()
    }

}
