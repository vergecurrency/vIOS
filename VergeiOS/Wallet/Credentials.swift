//
// Created by Swen van Zanten on 2019-02-12.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit
import CryptoSwift

public class Credentials {

    static let shared = Credentials()

    enum CredentialsError: Error {
        case invalidDeriver(value: String)
    }

    var seed: Data = Data()
    var network: Network = .mainnetXVG

    init() {
        //
    }

    public var privateKey: HDPrivateKey {
        return HDPrivateKey(seed: seed, network: network)
    }

    public var walletPrivateKey: HDPrivateKey {
        return try! privateKey.derived(at: 0, hardened: true)
    }

    public var requestPrivateKey: HDPrivateKey {
        return try! privateKey.derived(at: 1, hardened: true).derived(at: 0)
    }

    public var bip44PrivateKey: HDPrivateKey {
        return try! privateKey
            .derived(at: 44, hardened: true)
            .derived(at: 0, hardened: true)
            .derived(at: 0, hardened: true)
    }

    public var publicKey: HDPublicKey {
        return bip44PrivateKey.extendedPublicKey()
    }

    public var personalEncryptingKey: String {
        let data = Crypto.sha256(requestPrivateKey.privateKey().data)
        let key = "personalKey".data(using: .utf8)!

        var b2 = try! HMAC(key: key.bytes, variant: .sha256).authenticate(data.bytes)

        return Data(b2[0..<16]).base64EncodedString()
    }

    public var sharedEncryptingKey: String {
        var sha256Data = walletPrivateKey.privateKey().data.sha256()

        return sha256Data[0..<16].base64EncodedString()
    }

    public func setSeed(mnemonic: [String], passphrase: String) {
        self.seed = Mnemonic.seed(mnemonic: mnemonic, passphrase: passphrase)
    }

    public func setNetwork(network: Network) {
        self.network = network
    }

    public func privateKeyBy(path: String, privateKey: HDPrivateKey) throws -> PrivateKey {
        var key = privateKey
        for deriver in path.replacingOccurrences(of: "m/", with: "").split(separator: "/") {
            guard let deriverInt32 = UInt32(deriver) else {
                throw CredentialsError.invalidDeriver(value: String(deriver))
            }

            key = try key.derived(at: deriverInt32)
        }

        return key.privateKey()
    }

}
