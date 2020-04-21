//
// Created by Swen van Zanten on 2019-04-11.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import Swinject
import Logging

class EventServiceProvider: ServiceProvider {

    private var nc: NotificationCenter!
    private var subscribers: [String] = []
    private var resolvedObservers: [NSObjectProtocol] = []

    /// Register all event subscriber services.
    override func register() {
        self.nc = NotificationCenter.default

        self.register(name: ConfigurationSubscriber.typeName) { r in
            return ConfigurationSubscriber(
                applicationRepository: r.resolve(ApplicationRepository.self)!,
                walletClient: r.resolve(WalletClientProtocol.self)!,
                walletManager: r.resolve(WalletManagerProtocol.self)!,
                log: r.resolve(Logger.self)!
            )
        }

        self.register(name: WalletNotificationsSubscriber.typeName) { r in
            return WalletNotificationsSubscriber(walletClient: r.resolve(WalletClientProtocol.self)!)
        }

        self.register(name: TorConnectionSubscriber.typeName) { r in
            return TorConnectionSubscriber(
                fiatRateTicker: r.resolve(FiatRateTicker.self)!,
                applicationRepository: r.resolve(ApplicationRepository.self)!,
                walletTicker: r.resolve(WalletTicker.self)!
            )
        }

        self.register(name: WatchSubscriber.typeName) { r in
            return WatchSubscriber(watchSyncManager: r.resolve(WatchSyncManager.self)!)
        }

        self.register(name: WalletSubscriber.typeName) { r in
            return WalletSubscriber(
                walletTicker: r.resolve(WalletTicker.self)!,
                walletClient: r.resolve(WalletClientProtocol.self)!,
                fiatRateTicker: r.resolve(FiatRateTicker.self)!,
                shortcutsManager: r.resolve(ShortcutsManager.self)!,
                applicationRepository: r.resolve(ApplicationRepository.self)!,
                transactionManager: r.resolve(TransactionManager.self)!,
                torClient: r.resolve(TorClient.self)!
            )
        }

        self.register(name: CurrencySubscriber.typeName) { r in
            return CurrencySubscriber(fiatRateTicker: r.resolve(FiatRateTicker.self)!, log: r.resolve(Logger.self)!)
        }
    }

    /// Boot all event subscribers
    override func boot() {
        for subscriber in subscribers {
            guard let resolvedSubscriber = self.container.resolve(SubscriberProtocol.self, name: subscriber) else {
                fatalError("Couldn't resolve \(subscriber)")
            }

            for event in resolvedSubscriber.getSubscribedEvents() {
                let resolvedObserver = self.nc.addObserver(
                    forName: event.key,
                    object: nil,
                    queue: .main
                ) { notification in
                    resolvedSubscriber.perform(event.value, with: notification)
                }

                self.resolvedObservers.append(resolvedObserver)
            }
        }
    }

    /// Helper to remove some boilerplate
    private func register(name: String, factory: @escaping (Swinject.Resolver) -> SubscriberProtocol) {
        self.subscribers.append(name)

        self.container.register(SubscriberProtocol.self, name: name) { r in
            factory(r)
        }
    }
}
