//
//  WatchSubscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

class WatchSubscriber: Subscriber {
    private let watchSyncManager: WatchSyncManager

    init(watchSyncManager: WatchSyncManager) {
        self.watchSyncManager = watchSyncManager
        super.init()
    }

    @objc func syncWatchCurrency(notification: Notification) {
        self.watchSyncManager.syncCurrency()
    }

    @objc func syncWatchAmount(notification: Notification) {
        self.watchSyncManager.syncAmount()
    }

    @objc func syncWatchAddress(notification: Notification) {
        self.watchSyncManager.syncAddress(notification: notification)
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        [
            .didChangeCurrency: #selector(syncWatchCurrency(notification:)),
            .didChangeWalletAmount: #selector(syncWatchAmount(notification:)),
            .didChangeReceiveAddress: #selector(syncWatchAddress(notification:))
        ]
    }
}
