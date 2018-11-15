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
        // This should fail when no mnemonic is set.
        return HDPrivateKey(seed: Mnemonic.seed(mnemonic: ApplicationManager.default.mnemonic!), network: network)
    }

    private var requestPrivateKey: HDPrivateKey {
        return try! privateKey.derived(at: 1, hardened: true).derived(at: 0)
    }

    private var bip44PrivateKey: HDPrivateKey {
        return try! privateKey
            .derived(at: 44, hardened: true)
            .derived(at: 1, hardened: true)
            .derived(at: 0, hardened: true)
    }

    private var publicKey: HDPublicKey {
        return bip44PrivateKey.extendedPublicKey()
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
        let encWalletName = encryptMessage(plaintext: walletName)

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

    public func createAddress(completion: @escaping (_ error: Error?, _ address: AddressInfo?) -> Void) {
        postRequest(url: "/v3/addresses/", arguments: nil) { data, response, error in
            if let data = data {
                do {
                    let addressInfo = try JSONDecoder().decode(AddressInfo.self, from: data)
                    completion(error, addressInfo)
                } catch {
                    print(error.localizedDescription)
                    completion(error, nil)
                }
            }
        }
    }

    public func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: WalletBalanceInfo?) -> Void) {
        getRequest(url: "/v1/balance/") { data, response, error in
            if let data = data {
                do {
                    let balanceInfo = try JSONDecoder().decode(WalletBalanceInfo.self, from: data)
                    completion(error, balanceInfo)
                } catch {
                    print(error.localizedDescription)
                    completion(error, nil)
                }
            }
        }
    }

    public func getMainAddresses(
        options: WalletAddressesOptions? = nil,
        completion: @escaping (_ addresses: [AddressInfo]) -> Void
    ) {
        getRequest(url: "/v1/addresses/") { data, response, error in
            if let data = data {
                do {
                    let addresses = try JSONDecoder().decode([AddressInfo].self, from: data)
                    completion(addresses)
                } catch {
                    print(error.localizedDescription)
                    completion([])
                }
            }
        }
    }

    public func getTxHistory(
        skip: Int = 0,
        limit: Int = 15,
        completion: @escaping (_ transactions: [TxHistory]) -> Void
    ) {
        getRequest(url: "/v1/txhistory/?skip=\(skip)&limit=\(limit)&includeExtendedInfo=1") { data, response, error in
            if let data = data {
                do {
                    let transactions = try JSONDecoder().decode([TxHistory].self, from: data)
                    completion(transactions)
                } catch {
                    print(error.localizedDescription)
                    completion([])
                }
            }
        }
    }

    public func getUnspentOutputs(address: String? = nil, completion: @escaping (_ unspentOutputs: [UnspentOutput]) -> Void) {
        getRequest(url: "/v1/utxos/") { data, response, error in
            if let data = data {
                do {
                    print(try JSON(data: data))
                    let unspentOutputs = try JSONDecoder().decode([UnspentOutput].self, from: data)
                    completion(unspentOutputs)
                } catch {
                    print(error.localizedDescription)
                    completion([])
                }
            }
        }
    }

    public func createTxProposal(proposal: TxProposal, completion: @escaping (_ txp: TxProposalResponse?, _ error: Error?) -> Void) {
        var arguments = JSON()
        var output = JSON()
        output["toAddress"].stringValue = proposal.address
        output["amount"].intValue = Int(proposal.amount.doubleValue * Config.satoshiDivider)
        output["message"].null = nil

        arguments["outputs"] = [output]
        arguments["message"].stringValue = encryptMessage(plaintext: proposal.message)
        arguments["feePerKb"].intValue = 10000
        arguments["payProUrl"].null = nil

        postRequest(url: "/v2/txproposals/", arguments: arguments) { data, response, error in
            if let data = data {
                do {
                    return completion(try JSONDecoder().decode(TxProposalResponse.self, from: data), nil)
                } catch {
                    print(try! JSON(data: data))

                    return completion(nil, error)
                }
            } else {
                return completion(nil, error)
            }
        }
    }

    public func publishTxProposal(txp: TxProposalResponse, completion: @escaping (_ txp: TxProposalResponse?, _ error: Error?) -> Void) {
        let unsignedTx = getUnsignedTx(txp: txp)

        let transactionHash = unsignedTx.tx.serialized().hex

        var arguments = JSON()
        arguments["proposalSignature"].stringValue = self.signMessage(transactionHash)

        postRequest(
            url: "/v1/txproposals/\(txp.id)/publish/",
            arguments: arguments
        ) { data, response, error in
            if let data = data {
                do {
                    return completion(try JSONDecoder().decode(TxProposalResponse.self, from: data), nil)
                } catch {
                    print(try! JSON(data: data), txp)

                    return completion(nil, error)
                }
            } else {
                return completion(nil, error)
            }
        }
    }

    public func signTxProposal(txp: TxProposalResponse, completion: @escaping (_ txp: TxProposalResponse?, _ error: Error?) -> Void) {
        let unsignedTx = getUnsignedTx(txp: txp)

        let privateKeys: [PrivateKey] = txp.inputs.map { output in
            return privateKeyBy(path: output.path, privateKey: bip44PrivateKey)
        }

        var arguments = JSON()
        let signatures = JSON(signTx(unsignedTx: unsignedTx, keys: privateKeys))
        arguments["signatures"] = signatures

        postRequest(
            url: "/v1/txproposals/\(txp.id)/signatures/",
            arguments: arguments
        ) { data, response, error in
            if let data = data {
                do {
                    return completion(try JSONDecoder().decode(TxProposalResponse.self, from: data), nil)
                } catch {
                    print(try! JSON(data: data), txp)

                    return completion(nil, error)
                }
            } else {
                return completion(nil, error)
            }
        }
    }

    public func broadcastTxProposal(txp: TxProposalResponse, completion: @escaping (_ txp: TxProposalResponse?, _ error: Error?) -> Void) {
        postRequest(
            url: "/v1/txproposals/\(txp.id)/broadcast/",
            arguments: nil
        ) { data, response, error in
            if let data = data {
                do {
                    return completion(try JSONDecoder().decode(TxProposalResponse.self, from: data), nil)
                } catch {
                    print(try! JSON(data: data), txp)

                    return completion(nil, error)
                }
            } else {
                return completion(nil, error)
            }
        }
    }

    private func getRequest(url: String, completion: @escaping URLCompletion) {
        let referencedUrl = addUrlReference(url)

        guard let url = URL(string: "\(baseUrl)\(referencedUrl)".urlify()) else {
            return completion(nil, nil, NSError(domain: "Wrong URL", code: 500))
        }

        let copayerId = getCopayerId()
        let signature = getSignature(url: referencedUrl, method: "get")

        print("Get request to: \(url)")
        print("With signature: \(signature)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(copayerId, forHTTPHeaderField: "x-identity")
        request.setValue(signature, forHTTPHeaderField: "x-signature")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }

        DispatchQueue.main.async {
            task.resume()
        }
    }

    private func postRequest(url: String, arguments: JSON?, completion: @escaping URLCompletion) {
        let uri = url
        guard let url = URL(string: "\(baseUrl)\(url)".urlify()) else {
            return completion(nil, nil, NSError(domain: "Wrong URL", code: 500))
        }

        do {
            var argumentsString = "{}"
            if let argumentsData = try arguments?.rawData() {
                argumentsString = String(data: argumentsData, encoding: .utf8) ?? "{}"
            }

            let copayerId = getCopayerId()
            let signature = getSignature(url: uri, method: "post", arguments: argumentsString)

            print("Post request to: \(url)")
            print("With signature: \(signature)")

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(copayerId, forHTTPHeaderField: "x-identity")
            request.setValue(signature, forHTTPHeaderField: "x-signature")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = argumentsString.data(using: .utf8)

            urlSession.dataTask(with: request) { data, response, error in
                completion(data, response, error)
            }.resume()
        } catch {
            return completion(nil, nil, error)
        }
    }

    private func getCopayerId() -> String {
        let xPubKey = publicKey.extended()
        let hash = sjcl.sha256Hash(data: xPubKey)

        return sjcl.hexFromBits(hash: hash)
    }

    private func getSignature(url: String, method: String, arguments: String = "{}") -> String {
        return signMessage([method, url, arguments].joined(separator: "|"))
    }

    private func signMessage(_ message: String) -> String {
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

    private func encryptMessage(plaintext: String) -> String {
        let key = sjcl.base64ToBits(encryptingKey: sharedEncryptingKey)

        return sjcl.encrypt(password: key, plaintext: plaintext, params: ["ks": 128, "iter": 1])
    }

    private func buildSecret(walletId: String) -> String {
        let widHex = Data(hex: walletId.replacingOccurrences(of: "-", with: ""))
        let widBase58 = Base58.encode(widHex!).padding(toLength: 22, withPad: "0", startingAt: 0)

        // TODO: Replace T with L when not using testnet!
        // TODO: Replace btc with verge when not using testnet!
        return "\(widBase58)\(privateKey.privateKey().toWIF())Tbtc"
    }

    private func addUrlReference(_ url: String) -> String {
        let referenceUrl = url.contains("?") ? "\(url)&" : "\(url)?"

        return "\(referenceUrl)r=\(Int.random(in: 10000 ... 99999))"
    }

    private func getUnsignedTx(txp: TxProposalResponse) -> UnsignedTransaction {
        let changeAddress: Address = try! AddressFactory.create(txp.changeAddress.address)
        let toAddress: Address = try! AddressFactory.create(txp.outputs.first!.toAddress)

        let unspentOutputs = txp.inputs
        let unspentTransactions: [UnspentTransaction] = unspentOutputs.map { output in
            return output.asUnspentTransaction()
        }

        let amount = txp.amount
        let totalAmount: Int64 = unspentTransactions.reduce(0) { $0 + $1.output.value }
        let change: Int64 = totalAmount - amount - txp.fee

        let lockingScriptChange = Script(address: changeAddress)
        let lockingScriptTo = Script(address: toAddress)

        let changeOutput = TransactionOutput(value: change, lockingScript: lockingScriptChange!.data)
        let toOutput = TransactionOutput(value: amount, lockingScript: lockingScriptTo!.data)

        let unsignedInputs: [TransactionInput] = unspentOutputs.map { output in
            return output.asInputTransaction()
        }

        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: [changeOutput, toOutput], lockTime: 0)
        let unsignedTx = UnsignedTransaction(tx: tx, utxos: unspentTransactions)
        return unsignedTx
    }

    public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) -> [String] {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
        }

        var hexes = [String]()
        // Signing
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BTC.ALL)
            let signature: Data = try! Crypto.sign(sighash, privateKey: keys[i])

            hexes.append(signature.hex)
        }

        return hexes
    }

    private func privateKeyBy(path: String, privateKey: HDPrivateKey) -> PrivateKey {
        var key = privateKey
        for deriver in path.replacingOccurrences(of: "m/", with: "").split(separator: "/") {
            key = try! key.derived(at: UInt32(deriver) ?? 0)
        }

        return key.privateKey()
    }
}
