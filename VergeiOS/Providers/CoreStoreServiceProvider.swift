//
// Created by Swen van Zanten on 2019-04-11.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import CoreStore

class CoreStoreServiceProvider: ServiceProvider {

    override func boot() {
        do {
            CoreStoreDefaults.dataStack = DataStack(
                xcodeModelName: "CoreData",
                bundle: Bundle.main,
                migrationChain: [
                    "VergeiOS",
                    "VergeiOS 2"
                ]
            )

            try CoreStore.addStorageAndWait(
                SQLiteStore(fileName: "VergeiOS.sqlite", localStorageOptions: .allowSynchronousLightweightMigration)
            )
        } catch {
            print(error.localizedDescription)
        }
    }

}
