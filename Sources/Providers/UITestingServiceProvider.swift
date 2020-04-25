//
//  UITestingServiceProvider.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

class UITestingServiceProvider: ServiceProvider {
    override func boot() {
        if CommandLine.arguments.contains("--uitesting-reset") {
            NotificationCenter.default.post(name: .didDisconnectWallet, object: nil)
        }
    }
}
