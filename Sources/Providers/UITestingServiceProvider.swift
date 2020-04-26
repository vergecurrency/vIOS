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
        if !CommandLine.arguments.contains("--uitesting") {
            return
        }

        if CommandLine.arguments.contains("--uitesting-reset") {
            NotificationCenter.default.post(name: .didDisconnectWallet, object: nil)
        }

        let testVws = "http://localhost:3232/vws/api/"
        let applicationRepository = container.resolve(ApplicationRepository.self)
        let walletClient = container.resolve(WalletClientProtocol.self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            applicationRepository?.walletServiceUrl = testVws
            walletClient?.resetServiceUrl(baseUrl: testVws)
        }
    }
}
