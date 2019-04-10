//
// Created by Swen van Zanten on 2019-04-11.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import Swinject
import SwinjectStoryboard

class Application {

    // The container globally available.
    private(set) static var container: Container!

    // Register all service providers.
    let serviceProviders: [ServiceProvider.Type] = [
        ApplicationServiceProvider.self,
        HttpServiceProvider.self,
        WalletServiceProvider.self,
        SetupViewServiceProvider.self,
        WalletViewServiceProvider.self,
        AddressesViewServiceProvider.self,
        SendViewServiceProvider.self,
        ReceiveViewServiceProvider.self,
        SettingsViewServiceProvider.self,
        EventServiceProvider.self,
    ]

    var initializedServiceProviders: [ServiceProvider] = []

    // Init the application with a container.
    public init(container: Container) {
        Application.container = container
    }

    // Boot the service providers.
    public func boot() {
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
    }

}
