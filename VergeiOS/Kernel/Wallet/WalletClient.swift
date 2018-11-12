//
// Created by Swen van Zanten on 08/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit
import SwiftyJSON

public class WalletClient {

    public static let shared = WalletClient(baseUrl: Config.bwsEndpoint, urlSession: TorClient.shared.session)

    private let sjcl = SJCL()

    private var baseUrl: String = ""
    private var urlSession: URLSession!

    private let network = Network.testnet

    private var privateKey: HDPrivateKey {
        return HDPrivateKey(seed: Mnemonic.seed(mnemonic: ApplicationManager.default.mnemonic!), network: network)
    }

    private var requestPrivateKey: HDPrivateKey {
        return try! privateKey.derived(at: 1, hardened: true).derived(at: 0)
    }

    private var publicKey: HDPublicKey {
        return try! privateKey
            .derived(at: 44, hardened: true)
            .derived(at: 1, hardened: true)
            .derived(at: 0, hardened: true)
            .extendedPublicKey()
    }

    private var sharedEncryptingKey: String {
        var sha256Data = Crypto.sha256(privateKey.privateKey().raw)
        sha256Data.removeSubrange(0..<16)

        return sha256Data.base64EncodedString()
    }

    private typealias URLCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

    public init(baseUrl: String, urlSession: URLSession) {
        self.baseUrl = baseUrl
        self.urlSession = urlSession
    }

    public func createWallet(
        walletName: String,
        copayerName: String,
        m: Int,
        n: Int,
        options: WalletOptions?,
        completion: @escaping (_ error: Error?, _ secret: String?) -> Void
    ) {
        let key = sjcl.base64ToBits(encryptingKey: sharedEncryptingKey)
        let encWalletName = sjcl.encrypt(password: key, plaintext: walletName, params: ["ks": 128, "iter": 1])

        var args = JSON()
        args["name"].stringValue = encWalletName
        args["pubKey"].stringValue = publicKey.publicKey().description
        args["m"].intValue = m
        args["n"].intValue = n

        postRequest(url: "/v2/wallets/", arguments: args) { data, response, error in
            if let data = data {
                do {
                    let walletId = try JSONDecoder().decode(WalletID.self, from: data)

                    ApplicationManager.default.walletId = walletId.identifier
                    ApplicationManager.default.walletName = walletName
                    ApplicationManager.default.walletSecret = self.buildSecret(walletId: walletId.identifier)

                    completion(nil, walletId.identifier)
                } catch {
                    completion(error, nil)
                }
            }
        }
    }

    public func openWallet(completion: @escaping (_ error: Error?, _ walletInfo: WalletInfo?) -> Void) {

    }

    public func createAddress(completion: @escaping (_ error: Error?, _ address: String?) -> Void) {

    }

    public func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: WalletBalanceInfo?) -> Void) {
        getRequest(url: "/v1/balance/") { data, response, error in
            if let data = data {
                do {
                    let balanceInfo = try JSONDecoder().decode(WalletBalanceInfo.self, from: data)
                    completion(error, balanceInfo)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    public func getMainAddresses(
        options: WalletAddressesOptions? = nil,
        completion: @escaping (_ addresses: [String]) -> Void
    ) {
        getRequest(url: "/v1/addresses/") { data, response, error in
            if let data = data {
                do {
                    print(try JSON(data: data))
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func getRequest(url: String, completion: @escaping URLCompletion) {
        var nurl = url.contains("?") ? "\(url)&" : "\(url)?";
        nurl = "\(nurl)r=\(Int.random(in: 10000 ... 99999))"

        guard let url = URL(string: "\(baseUrl)\(nurl)".urlify()) else {
            return completion(nil, nil, NSError(domain: "Wrong URL", code: 500))
        }

        let copayerId = getCopayerId()
        let signature = getSignature(url: nurl, method: "get")

        print(url)
        print(signature)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(copayerId, forHTTPHeaderField: "x-identity")
        request.setValue(signature, forHTTPHeaderField: "x-signature")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        urlSession.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }.resume()
    }

    private func postRequest(url: String, arguments: JSON, completion: @escaping URLCompletion) {
        guard let url = URL(string: "\(baseUrl)\(url)".urlify()) else {
            return completion(nil, nil, NSError(domain: "Wrong URL", code: 500))
        }

        let copayerId = getCopayerId()
        let signature = getSignature(url: url.absoluteString, method: "post", arguments: arguments)

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(copayerId, forHTTPHeaderField: "x-identity")
            request.setValue(signature, forHTTPHeaderField: "x-signature")
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try arguments.rawData()

            urlSession.dataTask(with: request) { data, response, error in
                completion(data, response, error)
            }.resume()
        } catch {
            completion(nil, nil, error)
        }
    }

    private func getCopayerId() -> String {
        let xPubKey = publicKey.extended()
        let hash = sjcl.sha256Hash(data: xPubKey)

        return sjcl.hexFromBits(hash: hash)
    }

    private func getSignature(url: String, method: String, arguments: JSON? = nil) -> String {
        var items = [method, url]
        if let argumentsString = arguments?.rawString() {
            items.append(argumentsString)
        } else {
            items.append("{}")
        }

        let message = items.joined(separator: "|")

        guard let messageData = message.data(using: .utf8) else {
            return ""
        }

        var ret = Crypto.sha256sha256(messageData)
        ret.reverse()
        ret.reverse()

        do {
            return try Crypto.sign(ret, privateKey: requestPrivateKey.privateKey()).hex
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }

    private func buildSecret(walletId: String) -> String {
        let widHex = Data(hex: walletId.replacingOccurrences(of: "-", with: ""))
        let widBase58 = Base58.encode(widHex!).padding(toLength: 22, withPad: "0", startingAt: 0)

        // TODO: Replace T with L when not using testnet!
        // TODO: Replace btc with verge when not using testnet!
        return "\(widBase58)\(privateKey.privateKey().toWIF())Tbtc"
    }
}
