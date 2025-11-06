//
// Created by Swen van Zanten on 09/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct WalletInfo: Decodable {
        struct Error: DecodableError {
            enum Code: String, Decodable {
                case WalletNotFound = "WALLET_NOT_FOUND"
            }

            let code: Code
            let message: String
        }

        let id: String
        let version: String
        let createdOn: UInt32?
        let name: String
        let m: Int
        let n: Int
        let singleAddress: Bool
        let status: String
        let publicKeyRing: [PublicKeyRing]
        let copayers: [Copayer]
        let pubKey: String
        let coin: String
        let network: String
        let derivationStrategy: String
        let addressType: String
        let addressManager: AddressManager
        let scanStatus: String?
        let beRegistered: Bool
        let beAuthPrivateKey2: String?
        let beAuthPublicKey2: String?
        let nativeCashAddr: String?
        let isShared: Bool?
    }

    struct PublicKeyRing: Decodable {
        let xPubKey: String
        let requestPubKey: String
    }

    struct Copayer: Decodable {
        let id: String
        let version: Int
        let createdOn: UInt32?
        let coin: String
        let name: String
        let xPubKey: String
        let requestPubKey: String
        let signature: String
        let requestPubKeys: [RequestPubKey]
        let customData: String
    }

    struct RequestPubKey: Decodable {
        let key: String
        let signature: String
    }

    struct AddressManager: Decodable {
        let version: Int
        let derivationStrategy: String
        let receiveAddressIndex: Int
        let changeAddressIndex: Int
        let copayerIndex: Int
        let skippedPaths: [String]?

    }
}
