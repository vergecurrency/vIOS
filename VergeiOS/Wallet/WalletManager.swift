//
//  WalletManager.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26/10/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

class WalletManager: WalletManagerProtocol {
    let walletClient: WalletClientProtocol
    let walletTicker: WalletTicker
    let applicationRepository: ApplicationRepository

    let walletName = "ioswallet"
    let copayerName = "iosuser"
    let walletM = 1
    let walletN = 1

    init(walletClient: WalletClientProtocol, walletTicker: WalletTicker, applicationRepository: ApplicationRepository) {
        self.walletClient = walletClient
        self.walletTicker = walletTicker
        self.applicationRepository = applicationRepository
    }

    func joinWallet(createWallet: Bool = true, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        self.walletTicker.stop()

        self.walletClient.joinWallet(walletIdentifier: self.applicationRepository.walletId!) { error in
            if error == nil {
                return DispatchQueue.main.async {
                    self.walletTicker.start()
                    completion(nil)
                }
            }

            if !createWallet {
                return
            }

            print("Joining wallet failed... trying to create a new wallet")

            return self.createWallet(completion: completion)
        }
    }

    func createWallet(completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        self.walletTicker.stop()

        self.walletClient.createWallet(
            walletName: self.walletName,
            copayerName: self.copayerName,
            m: self.walletM,
            n: self.walletN,
            options: nil
        ) { error, secret in
            if (error != nil || secret == nil) {
                DispatchQueue.main.async {
                    completion(error)
                }

                return print(error ?? "")
            }

            self.joinWallet(createWallet: false, completion: completion)
        }
    }

    func synchronizeWallet(completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        self.walletClient.scanAddresses(completion: completion)
    }
}
