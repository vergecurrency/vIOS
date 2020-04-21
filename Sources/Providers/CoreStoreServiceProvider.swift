//
// Created by Swen van Zanten on 2019-04-11.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import CoreStore
import Logging

class CoreStoreServiceProvider: ServiceProvider {

    let dataStack: DataStack = {
        DataStack(
            xcodeModelName: "CoreData",
            bundle: Bundle.main,
            migrationChain: [
                "VergeiOS",
                "VergeiOS 2"
            ]
        )
    }()

    override func boot() {
        do {
            CoreStoreDefaults.dataStack = dataStack

            try self.dataStack.addStorageAndWait(
                SQLiteStore(fileName: "VergeiOS.sqlite", localStorageOptions: .allowSynchronousLightweightMigration)
            )

            self.container.register(DataStack.self) { _ in
                self.dataStack
            }
        } catch {
            self.container.resolve(Logger.self)?.error(
                "core store error during initialization: \(error.localizedDescription)"
            )
        }
    }

}
