//
// Created by Swen van Zanten on 2019-04-11.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import Swinject

class Application {

    // The container globally available.
    private(set) static var container: Container!

    // Register all service providers.
    private let serviceProviders: [ServiceProvider.Type] = [
        ApplicationServiceProvider.self,
        CoreStoreServiceProvider.self,
        EventServiceProvider.self,
        HttpServiceProvider.self,
        BlockchainServiceProvider.self,
        WalletServiceProvider.self,
        SetupViewServiceProvider.self,
        WalletViewServiceProvider.self,
        TransactionServiceProvider.self,
        SendViewServiceProvider.self,
        ReceiveViewServiceProvider.self,
        SettingsViewServiceProvider.self
    ]

    private var initializedServiceProviders: [ServiceProvider] = []

    private var booted: Bool = false

    // Init the application with a container.
    public init(container: Container) {
        Application.container = container
    }

    // Boot the service providers.
    public func boot() {
        if booted {
            return
        }

        // Initialize providers.
        for serviceProvider in self.serviceProviders {
            self.initializedServiceProviders.append(serviceProvider.init(container: Application.container))
        }

        // Register services.
        for serviceProvider in self.initializedServiceProviders {
            serviceProvider.register()
        }

        // Boot services.
        for serviceProvider in self.initializedServiceProviders {
            serviceProvider.boot()
        }

        self.booted = true
    }

}
