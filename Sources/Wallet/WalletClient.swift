//
// Created by Swen van Zanten on 08/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit
import SwiftyJSON
import CryptoSwift
import Logging

// swiftlint:disable file_length
public class WalletClient: WalletClientProtocol {

    enum WalletClientError: Error {
        case addressToScriptError(address: Address)
        case invalidDeriver(value: String)
        case invalidMessageData(message: String)
        case invalidWidHex(id: String)
        case invalidAddressReceived(address: AddressInfo?)
        case noOutputFound
        case walletNotFound
    }

    private let sjcl = SJCL()

    private let applicationRepository: ApplicationRepository
    private let credentials: Credentials
    private let torClient: TorClient
    private let log: Logger
    private let network: Network

    private var baseUrl: String = ""

    private typealias URLCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

    init(
        appRepo: ApplicationRepository,
        credentials: Credentials,
        torClient: TorClient,
        log: Logger,
        network: Network = .mainnetXVG
    ) {
        self.applicationRepository = appRepo
        self.baseUrl = appRepo.walletServiceUrl
        self.credentials = credentials
        self.torClient = torClient
        self.log = log
        self.network = network
    }

    public func resetServiceUrl(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    // MARK: Request methods

    private func getRequest(url: String, completion: @escaping URLCompletion) {
        let referencedUrl = url.addUrlReference()

        guard let url = URL(string: "\(baseUrl)\(referencedUrl)".urlify()) else {
            return completion(nil, nil, NSError(domain: "Wrong URL", code: 500))
        }

        do {
            let signature = try getSignature(url: referencedUrl, method: "get")
            let copayerId = self.getCopayerId()

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(self.getCopayerId(), forHTTPHeaderField: "x-identity")
            request.setValue(signature, forHTTPHeaderField: "x-signature")
            request.setValue("application/json", forHTTPHeaderField: "accept")

            self.log(request: request, signature: signature, copayerId: copayerId)

            self.request(request, completion: completion)
        } catch {
            return completion(nil, nil, error)
        }
    }

    private func postRequest(url: String, arguments: JSON?, completion: @escaping URLCompletion) {
        let uri = url
        guard let url = URL(string: "\(baseUrl)\(url)".urlify()) else {
            return completion(nil, nil, NSError(domain: "Wrong URL", code: 500))
        }

        do {
            let argumentsData = try arguments?.rawData()
            var argumentsString = "{}"
            if argumentsData != nil {
                argumentsString = String(data: argumentsData!, encoding: .utf8) ?? "{}"
                // Remove escaped slashes.
                argumentsString = argumentsString.replacingOccurrences(of: "\\/", with: "/")
            }

            let signature = try getSignature(url: uri, method: "post", arguments: argumentsString)
            let copayerId = self.getCopayerId()

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(self.getCopayerId(), forHTTPHeaderField: "x-identity")
            request.setValue(signature, forHTTPHeaderField: "x-signature")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = argumentsData

            self.log(request: request, signature: signature, copayerId: copayerId)

            self.request(request, completion: completion)
        } catch {
            return completion(nil, nil, error)
        }
    }

    private func deleteRequest(url: String, completion: @escaping URLCompletion) {
        let referencedUrl = url.addUrlReference()

        guard let url = URL(string: "\(baseUrl)\(referencedUrl)".urlify()) else {
            return completion(nil, nil, NSError(domain: "Wrong URL", code: 500))
        }

        do {
            let signature = try getSignature(url: referencedUrl, method: "delete")
            let copayerId = self.getCopayerId()
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue(copayerId, forHTTPHeaderField: "x-identity")
            request.setValue(signature, forHTTPHeaderField: "x-signature")
            request.setValue("application/json", forHTTPHeaderField: "accept")

            self.log(request: request, signature: signature, copayerId: copayerId)

            self.request(request, completion: completion)
        } catch {
            return completion(nil, nil, error)
        }
    }

    private func request(_ request: URLRequest, completion: @escaping URLCompletion) {
        let task = self.torClient.session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.log.error(LogMessage.WalletClientRequestError(error))
            }

            DispatchQueue.main.sync {
                completion(data, response, error)
            }
        }

        DispatchQueue.main.async {
            task.resume()
        }
    }

    private func getCopayerId() -> String {
        let xPubKey = self.credentials.publicKey.extended()
        let hash = self.sjcl.sha256Hash(data: "xvg\(xPubKey)")

        return self.sjcl.hexFromBits(hash: hash)
    }

    private func log(request: URLRequest, signature: String, copayerId: String) {
        self.log.notice(LogMessage.WalletClientRequestFired, metadata: [
            "method": Logger.MetadataValue(stringLiteral: request.httpMethod ?? ""),
            "url": Logger.MetadataValue(stringLiteral: request.url?.absoluteString ?? ""),
            "signature": Logger.MetadataValue(stringLiteral: signature),
            "copayerId": Logger.MetadataValue(stringLiteral: copayerId)
        ])
    }

}

// MARK: Wallets interaction methods

extension WalletClient {

    // swiftlint:disable function_parameter_count
    public func createWallet(
        walletName: String,
        copayerName: String,
        m: Int,
        n: Int,
        options: WalletOptions?,
        completion: @escaping (_ error: Error?, _ secret: String?) -> Void
    ) {
        // swiftlint:enable function_parameter_count
        let encWalletName = self.encryptMessage(
            plaintext: walletName,
            encryptingKey: self.credentials.sharedEncryptingKey
        )

        var args = JSON()
        args["name"].stringValue = encWalletName
        args["pubKey"].stringValue = self.credentials.walletPrivateKey.privateKey().publicKey().description
        args["m"].intValue = m
        args["n"].intValue = n
        args["coin"].stringValue = "xvg"
        args["network"].stringValue = "livenet"

        self.postRequest(url: "/v2/wallets/", arguments: args) { data, _, error in
            guard let data = data else {
                return completion(error, nil)
            }

            do {
                let walletId = try JSONDecoder().decode(WalletID.self, from: data)

                self.applicationRepository.walletId = walletId.identifier
                self.applicationRepository.walletName = walletName
                self.applicationRepository.walletSecret = try? self.buildSecret(walletId: walletId.identifier)

                completion(nil, walletId.identifier)
            } catch {
                completion(error, nil)
            }
        }
    }

    public func joinWallet(walletIdentifier: String, completion: @escaping (_ error: Error?) -> Void) {
        let xPubKey = self.credentials.publicKey.extended()
        let requestPubKey = self.credentials.requestPrivateKey.extendedPublicKey().publicKey().description

        let encCopayerName = self.encryptMessage(
            plaintext: "ios-copayer",
            encryptingKey: self.credentials.sharedEncryptingKey
        )
        let copayerSignatureHash = [encCopayerName, xPubKey, requestPubKey].joined(separator: "|")
        let customData = "{\"walletPrivKey\": \"\(self.credentials.walletPrivateKey.privateKey().description)\"}"

        var arguments = JSON()
        arguments["walletId"].stringValue = walletIdentifier
        arguments["coin"].stringValue = "xvg"
        arguments["name"].stringValue = encCopayerName
        arguments["xPubKey"].stringValue = xPubKey
        arguments["requestPubKey"].stringValue = requestPubKey
        arguments["customData"].stringValue = self.encryptMessage(
            plaintext: customData,
            encryptingKey: self.credentials.personalEncryptingKey
        )

        do {
            arguments["copayerSignature"].stringValue = try self.signMessage(
                copayerSignatureHash,
                privateKey: self.credentials.walletPrivateKey
            )
        } catch {
            return completion(error)
        }


        self.postRequest(url: "/v2/wallets/\(walletIdentifier)/copayers/", arguments: arguments) { data, _, error in
            guard let data = data else {
                return completion(error)
            }

            do {
                // TODO: Put this logic somewhere else
                let jsonResponse = try JSON(data: data)

                if jsonResponse["code"].stringValue == "WALLET_NOT_FOUND" {
                    return completion(WalletClientError.walletNotFound)
                }

                if jsonResponse["code"].stringValue == "COPAYER_REGISTERED" {
                    return self.openWallet { error in
                        completion(error)
                    }
                }

                completion(error)
            } catch {
                completion(error)
            }
        }
    }

    public func openWallet(completion: @escaping (_ error: Error?) -> Void) {
        // COPAYER_REGISTERED
        self.getRequest(url: "/v2/wallets/?includeExtendedInfo=1") { data, _, error in
            // TODO: Clean this up...
            guard let data = data else {
                return completion(error)
            }

            do {
                let jsonResponse = try JSON(data: data)

                completion(error)
            } catch {
                completion(error)
            }
        }
    }

}

// MARK: Wallet addresses interaction methods

extension WalletClient {

    public func scanAddresses(completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        self.postRequest(url: "/v1/addresses/scan", arguments: nil) { _, _, error in
            completion(error)
        }
    }

    public func createAddress(
        completion: @escaping (
            _ error: Error?,
            _ address: AddressInfo?,
            _ createAddressErrorResponse: CreateAddressErrorResponse?
        ) -> Void
    ) {
        self.postRequest(url: "/v4/addresses/", arguments: nil) { data, _, error in
            guard let data = data else {
                return completion(error, nil, nil)
            }

            do {
                let addressInfo = try JSONDecoder().decode(AddressInfo.self, from: data)
                let errorResponse = try JSONDecoder().decode(CreateAddressErrorResponse.self, from: data)

                // Make sure the received address is really your address.
                let addressByPath = try self.credentials.privateKeyBy(
                    path: addressInfo.path,
                    privateKey: self.credentials.bip44PrivateKey
                ).publicKey().toLegacy().description

                if addressInfo.address != addressByPath {
                    return completion(WalletClientError.invalidAddressReceived(address: addressInfo), nil, nil)
                }

                completion(nil, addressInfo, errorResponse)
            } catch {
                completion(error, nil, nil)
            }
        }
    }

    public func getMainAddresses(
        options: WalletAddressesOptions? = nil,
        completion: @escaping (_ error: Error?, _ addresses: [AddressInfo]) -> Void
    ) {
        var args: [String] = []
        var qs = ""

        if options?.limit != nil {
            args.append("limit=\(options!.limit!)")
        }

        if options?.reverse ?? false {
            args.append("reverse=1")
        }

        if args.count > 0 {
            qs = "?\(args.joined(separator: "&"))"
        }

        self.getRequest(url: "/v1/addresses/\(qs)") { data, _, error in
            guard let data = data else {
                return completion(error, [])
            }

            do {
                completion(nil, try JSONDecoder().decode([AddressInfo].self, from: data))
            } catch {
                completion(error, [])
            }
        }
    }

}

// MARK: Wallets info methods

extension WalletClient {

    public func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: WalletBalanceInfo?) -> Void) {
        self.getRequest(url: "/v1/balance/") { data, _, error in
            guard let data = data else {
                return completion(error, nil)
            }

            do {
                completion(error, try JSONDecoder().decode(WalletBalanceInfo.self, from: data))
            } catch {
                completion(error, nil)
            }
        }
    }

    public func getTxHistory(
        skip: Int? = nil,
        limit: Int? = nil,
        completion: @escaping (_ transactions: [TxHistory], Error?) -> Void
    ) {
        var url = "/v1/txhistory/?includeExtendedInfo=1"
        if (skip != nil && limit != nil) {
            url = "\(url)&skip=\(skip!)&limit=\(limit!)"
        }

        // TODO: do something with the possible errors...
        self.getRequest(url: url) { data, _, error in
            guard let data = data else {
                return completion([], error)
            }

            do {
                let transactions = try JSONDecoder().decode([TxHistory].self, from: data)
                var transformedTransactions: [TxHistory] = []
                for var transaction in transactions {
                    if let message = transaction.message {
                        transaction.message = self.decryptMessage(
                            ciphertext: message,
                            encryptingKey: self.credentials.sharedEncryptingKey
                        )
                    }

                    transformedTransactions.append(transaction)
                }

                completion(transformedTransactions, error)
            } catch {
                completion([], error)
            }
        }
    }

    public func getUnspentOutputs(
        address: String? = nil,
        completion: @escaping (_ unspentOutputs: [UnspentOutput]) -> Void
    ) {
        getRequest(url: "/v1/utxos/") { data, _, _ in
            guard let data = data else {
                return completion([])
            }

            completion((try? JSONDecoder().decode([UnspentOutput].self, from: data)) ?? [])
        }
    }

    public func getSendMaxInfo(completion: @escaping (_ sendMaxInfo: SendMaxInfo?) -> Void) {
        getRequest(url: "/v1/sendmaxinfo/") { data, _, _ in
            guard let data = data else {
                return completion(nil)
            }

            completion(try? JSONDecoder().decode(SendMaxInfo.self, from: data))
        }
    }

    public func watchRequestCredentialsForMethodPath(path: String) -> WatchRequestCredentials {
        var result = WatchRequestCredentials()
        let referencedUrl = path.addUrlReference()

        let url = "\(baseUrl)\(referencedUrl)".urlify()
        let copayerId = getCopayerId()

        if referencedUrl.contains("/v1/balance/") {
            var signature = ""
            do {
                signature = try getSignature(url: referencedUrl, method: "get")
            } catch {}

            result.url = url
            result.copayerId = copayerId
            result.signature = signature
        }

        return result
    }

}

// MARK: Tx proposals methods

extension WalletClient {

    public typealias TxProposalCompletion = (
        _ txp: TxProposalResponse?,
        _ errorResponse: TxProposalErrorResponse?,
        _ error: Error?
    ) -> Void

    public func createTxProposal(proposal: TxProposal, completion: @escaping TxProposalCompletion) {
        var arguments = JSON()
        var output = JSON()
        output["toAddress"].stringValue = proposal.address
        output["amount"].intValue = Int(proposal.amount.doubleValue * Constants.satoshiDivider)
        output["message"].null = nil

        arguments["outputs"] = [output]
        arguments["payProUrl"].null = nil

        if proposal.message.count > 0 {
            arguments["message"].stringValue = encryptMessage(
                plaintext: proposal.message,
                encryptingKey: credentials.sharedEncryptingKey
            )
        } else {
            arguments["message"].null = nil
        }

        postRequest(url: "/v3/txproposals/", arguments: arguments) { data, _, error in
            if let data = data {
                do {
                    return completion(try JSONDecoder().decode(TxProposalResponse.self, from: data), nil, nil)
                } catch {
                    return completion(nil, try? JSONDecoder().decode(TxProposalErrorResponse.self, from: data), error)
                }
            } else {
                return completion(nil, nil, error)
            }
        }
    }

    public func publishTxProposal(txp: TxProposalResponse, completion: @escaping TxProposalCompletion) {
        do {
            let unsignedTx = try getUnsignedTx(txp: txp)

            let transactionHash = unsignedTx.tx.serialized().hex

            var arguments = JSON()
            arguments["proposalSignature"].stringValue = try signMessage(
                transactionHash,
                privateKey: credentials.requestPrivateKey
            )

            postRequest(
                url: "/v2/txproposals/\(txp.id)/publish/",
                arguments: arguments
            ) { data, _, error in
                if let data = data {
                    do {
                        return completion(try JSONDecoder().decode(TxProposalResponse.self, from: data), nil, nil)
                    } catch {
                        return completion(
                            nil,
                            try? JSONDecoder().decode(TxProposalErrorResponse.self, from: data),
                            error
                        )
                    }
                } else {
                    return completion(nil, nil, error)
                }
            }
        } catch {
            completion(nil, nil, error)
        }
    }

    public func signTxProposal(txp: TxProposalResponse, completion: @escaping TxProposalCompletion) {
        do {
            let unsignedTx = try getUnsignedTx(txp: txp)

            let privateKeys: [PrivateKey] = try txp.inputs.map { output in
                return try credentials.privateKeyBy(path: output.path, privateKey: credentials.bip44PrivateKey)
            }

            var arguments = JSON()
            let signatures = JSON(try signTx(unsignedTx: unsignedTx, keys: privateKeys))
            arguments["signatures"] = signatures

            postRequest(
                url: "/v1/txproposals/\(txp.id)/signatures/",
                arguments: arguments
            ) { data, _, error in
                if let data = data {
                    do {
                        return completion(try JSONDecoder().decode(TxProposalResponse.self, from: data), nil, nil)
                    } catch {
                        return completion(
                            nil,
                            try? JSONDecoder().decode(TxProposalErrorResponse.self, from: data),
                            error
                        )
                    }
                } else {
                    return completion(nil, nil, error)
                }
            }
        } catch {
            completion(nil, nil, error)
        }
    }

    public func broadcastTxProposal(txp: TxProposalResponse, completion: @escaping TxProposalCompletion) {
        postRequest(
            url: "/v1/txproposals/\(txp.id)/broadcast/",
            arguments: nil
        ) { data, _, error in
            if let data = data {
                do {
                    return completion(try JSONDecoder().decode(TxProposalResponse.self, from: data), nil, nil)
                } catch {
                    return completion(nil, try? JSONDecoder().decode(TxProposalErrorResponse.self, from: data), error)
                }
            } else {
                return completion(nil, nil, error)
            }
        }
    }

    public func rejectTxProposal(txp: TxProposalResponse, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        postRequest(
            url: "/v1/txproposals/\(txp.id)/rejections/",
            arguments: nil
        ) { _, _, error in
            completion(error)
        }
    }

    public func deleteTxProposal(txp: TxProposalResponse, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        deleteRequest(url: "/v1/txproposals/\(txp.id)/") { _, _, error in
            completion(error)
        }
    }

    public func getTxProposals(completion: @escaping (_ txps: [TxProposalResponse], _ error: Error?) -> Void) {
        getRequest(url: "/v2/txproposals/") { data, _, error in
            if let error = error {
                return completion([], error)
            }

            guard let data = data else {
                return completion([], nil)
            }

            do {
                let txps = try JSONDecoder().decode([TxProposalResponse].self, from: data)

                completion(txps, nil)
            } catch {
                completion([], error)
            }
        }
    }

}

// MARK: Tx Signatures methods

extension WalletClient {

    private func getSignature(url: String, method: String, arguments: String = "{}") throws -> String {
        return try signMessage(
            [method, url, arguments].joined(separator: "|"),
            privateKey: credentials.requestPrivateKey
        )
    }

    private func signMessage(_ message: String, privateKey: HDPrivateKey) throws -> String {
        guard let messageData = message.data(using: .utf8) else {
            throw WalletClientError.invalidMessageData(message: message)
        }

        var ret = Crypto.sha256sha256(messageData)
        ret.reverse()
        ret.reverse()

        return try Crypto.sign(ret, privateKey: privateKey.privateKey()).hex
    }

    private func encryptMessage(plaintext: String, encryptingKey: String) -> String {
        let key = sjcl.base64ToBits(encryptingKey: encryptingKey)

        return sjcl.encrypt(password: key, plaintext: plaintext, params: ["ks": 128, "iter": 1])
    }

    private func decryptMessage(ciphertext: String, encryptingKey: String) -> String {
        let key = sjcl.base64ToBits(encryptingKey: encryptingKey)

        return sjcl.decrypt(password: key, ciphertext: ciphertext, params: [])
    }

    private func buildSecret(walletId: String) throws -> String {
        guard let widHex = Data(fromHex: walletId.replacingOccurrences(of: "-", with: "")) else {
            throw WalletClientError.invalidWidHex(id: walletId)
        }

        let widBase58 = Base58.encode(widHex).padding(toLength: 22, withPad: "0", startingAt: 0)

        return "\(widBase58)\(credentials.privateKey.privateKey().toWIF())Lxvg"
    }

    private func getUnsignedTx(txp: TxProposalResponse) throws -> UnsignedTransaction {
        guard let output = txp.outputs.first else {
            throw WalletClientError.noOutputFound
        }

        let changeAddress: Address = try AddressFactory.create(txp.changeAddress.address)
        let toAddress: Address = try AddressFactory.create(output.toAddress)

        let unspentOutputs = txp.inputs
        let unspentTransactions: [UnspentTransaction] = try unspentOutputs.map { output in
            return try output.asUnspentTransaction()
        }

        let amount = txp.amount
        let totalAmount: UInt64 = unspentTransactions.reduce(0) { $0 + $1.output.value }
        let change: UInt64 = UInt64(max(Int(totalAmount) - Int(amount) - Int(txp.fee), 0))

        guard let lockingScriptChange = Script(address: changeAddress) else {
            throw WalletClientError.addressToScriptError(address: changeAddress)
        }
        guard let lockingScriptTo = Script(address: toAddress) else {
            throw WalletClientError.addressToScriptError(address: toAddress)
        }

        let changeOutput = TransactionOutput(value: change, lockingScript: lockingScriptChange.data)
        let toOutput = TransactionOutput(value: amount, lockingScript: lockingScriptTo.data)

        let unsignedInputs: [TransactionInput] = try unspentOutputs.map { output in
            return try output.asInputTransaction()
        }

        var outputs: [TransactionOutput] = []

        outputs.append(toOutput)

        if output.stealth == true {
            let ephemeral = PrivateKey(
                data: Data(hex: output.ephemeralPrivKey!),
                network: .mainnetXVG,
                isPublicKeyCompressed: true
            )

            let opReturnMeta = try Script()
                .append(.OP_RETURN)
                .appendData(ephemeral.publicKey().data)

            let opReturnOutput = TransactionOutput(value: 0, lockingScript: opReturnMeta.data)
            outputs.append(opReturnOutput)
        }

        if change > 0 {
            outputs.append(changeOutput)
        }

        outputs = outputs.sortByIndices(indices: txp.outputOrder.map { Int($0) })

        let tx = Transaction(
            version: 1,
            timestamp: txp.createdOn,
            inputs: unsignedInputs,
            outputs: outputs,
            lockTime: 0
        )

        return UnsignedTransaction(tx: tx, utxos: unspentTransactions)
    }

    private func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) throws -> [String] {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(
                version: unsignedTx.tx.version,
                timestamp: unsignedTx.tx.timestamp,
                inputs: inputsToSign,
                outputs: unsignedTx.tx.outputs,
                lockTime: unsignedTx.tx.lockTime
            )
        }

        var hexes = [String]()
        // Signing
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)

            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
            guard let key = keysOfUtxo.first else {
                //print("No keys to this txout : \(utxo.output.value)")
                continue
            }
            //print("Value of signing txout : \(utxo.output.value)")
            //print(key.data.hex)

            let sighash: Data = transactionToSign.signatureHash(
                for: utxo.output,
                inputIndex: i,
                hashType: SighashType.BTC.ALL
            )

            let signature: Data = try Crypto.sign(sighash, privateKey: key)

            hexes.append(signature.hex)
        }

        return hexes
    }

}
// swiftlint:enable file_length
