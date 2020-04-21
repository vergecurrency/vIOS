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
        case invalidAddressReceived(address: Vws.AddressInfo?)
        case noOutputFound
    }

    private let sjcl = SJCL()

    private let applicationRepository: ApplicationRepository
    private let credentials: Credentials
    private let httpSession: HttpSessionProtocol
    private let log: Logger
    private let network: Network

    private var baseUrl: String = ""

    private typealias URLCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

    init(
        appRepo: ApplicationRepository,
        credentials: Credentials,
        httpSession: HttpSessionProtocol,
        log: Logger,
        network: Network = .mainnetXVG
    ) {
        self.applicationRepository = appRepo
        self.baseUrl = appRepo.walletServiceUrl
        self.credentials = credentials
        self.httpSession = httpSession
        self.log = log
        self.network = network
    }

    func resetServiceUrl(baseUrl: String) {
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
        self.httpSession.dataTask(with: request).then { response in
            completion(response.data, response.urlResponse, nil)
        }.catch { error in
            self.log.error("wallet client request error: \(error.localizedDescription)")

            completion(nil, nil, error)
        }
    }

    private func getCopayerId() -> String {
        let xPubKey = self.credentials.publicKey.extended()
        let hash = self.sjcl.sha256Hash(data: "xvg\(xPubKey)")

        return self.sjcl.hexFromBits(hash: hash)
    }

    private func log(request: URLRequest, signature: String, copayerId: String) {
        self.log.info("wallet client request fired", metadata: [
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
    func createWallet(
        walletName: String,
        copayerName: String,
        m: Int,
        n: Int,
        options: Vws.WalletOptions?,
        completion: @escaping (Vws.WalletID?, Vws.WalletID.Error?, Error?) -> Void
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
                return completion(nil, nil, error)
            }

            do {
                completion(try JSONDecoder().decode(Vws.WalletID.self, from: data), nil, nil)
            } catch {
                let errorResponse = try? JSONDecoder().decode(Vws.WalletID.Error.self, from: data)
                let returnError = errorResponse == nil ? error : nil

                completion(nil, errorResponse, returnError)
            }
        }
    }

    func joinWallet(
        walletIdentifier: String,
        completion: @escaping (Vws.WalletJoin?, Vws.WalletJoin.Error?, Error?) -> Void
    ) {
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
            return completion(nil, nil, error)
        }


        self.postRequest(url: "/v2/wallets/\(walletIdentifier)/copayers/", arguments: arguments) { data, _, error in
            guard let data = data else {
                return completion(nil, nil, error)
            }

            do {
                completion(try JSONDecoder().decode(Vws.WalletJoin.self, from: data), nil, nil)
            } catch {
                let joinWalletError = try? JSONDecoder().decode(Vws.WalletJoin.Error.self, from: data)
                let returnError = joinWalletError == nil ? error : nil

                completion(nil, joinWalletError, returnError)
            }
        }
    }

    func openWallet(completion: @escaping (Vws.WalletStatus?, Vws.WalletStatus.Error?, Error?) -> Void) {
        self.getRequest(url: "/v2/wallets/?includeExtendedInfo=1") { data, _, error in
            guard let data = data else {
                return completion(nil, nil, error)
            }

            do {
                completion(try JSONDecoder().decode(Vws.WalletStatus.self, from: data), nil, nil)
            } catch {
                let walletError = try? JSONDecoder().decode(Vws.WalletStatus.Error.self, from: data)
                let returnError = walletError == nil ? error : nil

                completion(nil, walletError, returnError)
            }
        }
    }

}

// MARK: Wallet addresses interaction methods

extension WalletClient {

    func scanAddresses(completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        self.postRequest(url: "/v1/addresses/scan", arguments: nil) { _, _, error in
            completion(error)
        }
    }

    func createAddress(
        completion: @escaping (
            _ error: Error?,
            _ address: Vws.AddressInfo?,
            _ createAddressErrorResponse: Vws.CreateAddressError?
        ) -> Void
    ) {
        self.postRequest(url: "/v4/addresses/", arguments: nil) { data, _, error in
            guard let data = data else {
                return completion(error, nil, nil)
            }

            do {
                let addressInfo = try JSONDecoder().decode(Vws.AddressInfo.self, from: data)

                // Make sure the received address is really your address.
                let addressByPath = try self.credentials.privateKeyBy(
                    path: addressInfo.path,
                    privateKey: self.credentials.bip44PrivateKey
                ).publicKey().toLegacy().description

                if addressInfo.address != addressByPath {
                    return completion(WalletClientError.invalidAddressReceived(address: addressInfo), nil, nil)
                }

                completion(nil, addressInfo, nil)
            } catch {
                let errorResponse = try? JSONDecoder().decode(Vws.CreateAddressError.self, from: data)

                completion(error, nil, errorResponse)
            }
        }
    }

    func getMainAddresses(
        options: Vws.WalletAddressesOptions? = nil,
        completion: @escaping (_ error: Error?, _ addresses: [Vws.AddressInfo]) -> Void
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
                completion(nil, try JSONDecoder().decode([Vws.AddressInfo].self, from: data))
            } catch {
                completion(error, [])
            }
        }
    }

}

// MARK: Wallets info methods

extension WalletClient {

    func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: Vws.WalletBalanceInfo?) -> Void) {
        self.getRequest(url: "/v1/balance/") { data, _, error in
            guard let data = data else {
                return completion(error, nil)
            }

            do {
                completion(error, try JSONDecoder().decode(Vws.WalletBalanceInfo.self, from: data))
            } catch {
                completion(error, nil)
            }
        }
    }

    func getTxHistory(
        skip: Int? = nil,
        limit: Int? = nil,
        completion: @escaping ([Vws.TxHistory], Error?) -> Void
    ) {
        var url = "/v1/txhistory/?includeExtendedInfo=1"
        if (skip != nil && limit != nil) {
            url = "\(url)&skip=\(skip!)&limit=\(limit!)"
        }

        self.getRequest(url: url) { data, _, error in
            guard let data = data else {
                return completion([], error)
            }

            do {
                let transactions = try JSONDecoder().decode([Vws.TxHistory].self, from: data)
                var transformedTransactions: [Vws.TxHistory] = []
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

    func getUnspentOutputs(
        address: String? = nil,
        completion: @escaping ([Vws.UnspentOutput], Error?) -> Void
    ) {
        self.getRequest(url: "/v1/utxos/") { data, _, error in
            guard let data = data else {
                return completion([], error)
            }

            do {
                completion(try JSONDecoder().decode([Vws.UnspentOutput].self, from: data), error)
            } catch {
                completion([], error)
            }
        }
    }

    func getSendMaxInfo(completion: @escaping (Vws.SendMaxInfo?, Error?) -> Void) {
        self.getRequest(url: "/v1/sendmaxinfo/") { data, _, error in
            guard let data = data else {
                return completion(nil, error)
            }

            do {
                completion(try JSONDecoder().decode(Vws.SendMaxInfo.self, from: data), error)
            } catch {
                completion(nil, error)
            }
        }
    }

    func watchRequestCredentialsForMethodPath(path: String) throws -> WatchRequestCredentials {
        var result = WatchRequestCredentials()
        let referencedUrl = path.addUrlReference()

        let url = "\(self.baseUrl)\(referencedUrl)".urlify()
        let copayerId = self.getCopayerId()

        if referencedUrl.contains("/v1/balance/") {
            let signature = try self.getSignature(url: referencedUrl, method: "get")

            result.url = url
            result.copayerId = copayerId
            result.signature = signature
        }

        return result
    }

}

// MARK: Tx proposals methods

extension WalletClient {

    typealias TxProposalCompletion = (
        _ txp: Vws.TxProposalResponse?,
        _ errorResponse: Vws.TxProposalErrorResponse?,
        _ error: Error?
    ) -> Void

    func createTxProposal(proposal: Vws.TxProposal, completion: @escaping TxProposalCompletion) {
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
                    return completion(try JSONDecoder().decode(Vws.TxProposalResponse.self, from: data), nil, nil)
                } catch {
                    return completion(
                        nil,
                        try? JSONDecoder().decode(Vws.TxProposalErrorResponse.self, from: data),
                        error
                    )
                }
            } else {
                return completion(nil, nil, error)
            }
        }
    }

    func publishTxProposal(txp: Vws.TxProposalResponse, completion: @escaping TxProposalCompletion) {
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
                        return completion(try JSONDecoder().decode(Vws.TxProposalResponse.self, from: data), nil, nil)
                    } catch {
                        return completion(
                            nil,
                            try? JSONDecoder().decode(Vws.TxProposalErrorResponse.self, from: data),
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

    func signTxProposal(txp: Vws.TxProposalResponse, completion: @escaping TxProposalCompletion) {
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
                        return completion(try JSONDecoder().decode(Vws.TxProposalResponse.self, from: data), nil, nil)
                    } catch {
                        return completion(
                            nil,
                            try? JSONDecoder().decode(Vws.TxProposalErrorResponse.self, from: data),
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

    func broadcastTxProposal(txp: Vws.TxProposalResponse, completion: @escaping TxProposalCompletion) {
        postRequest(
            url: "/v1/txproposals/\(txp.id)/broadcast/",
            arguments: nil
        ) { data, _, error in
            if let data = data {
                do {
                    return completion(try JSONDecoder().decode(Vws.TxProposalResponse.self, from: data), nil, nil)
                } catch {
                    return completion(
                        nil,
                        try? JSONDecoder().decode(Vws.TxProposalErrorResponse.self, from: data),
                        error
                    )
                }
            } else {
                return completion(nil, nil, error)
            }
        }
    }

    func rejectTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping (_ error: Error?) -> Void = { _ in }
    ) {
        postRequest(
            url: "/v1/txproposals/\(txp.id)/rejections/",
            arguments: nil
        ) { _, _, error in
            completion(error)
        }
    }

    func deleteTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping (_ error: Error?) -> Void = { _ in }
    ) {
        deleteRequest(url: "/v1/txproposals/\(txp.id)/") { _, _, error in
            completion(error)
        }
    }

    func getTxProposals(completion: @escaping (_ txps: [Vws.TxProposalResponse], _ error: Error?) -> Void) {
        getRequest(url: "/v2/txproposals/") { data, _, error in
            if let error = error {
                return completion([], error)
            }

            guard let data = data else {
                return completion([], nil)
            }

            do {
                let txps = try JSONDecoder().decode([Vws.TxProposalResponse].self, from: data)

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
        return try self.signMessage(
            [method, url, arguments].joined(separator: "|"),
            privateKey: self.credentials.requestPrivateKey
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

    private func getUnsignedTx(txp: Vws.TxProposalResponse) throws -> UnsignedTransaction {
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
                continue
            }

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
