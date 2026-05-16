//
// Created by Swen van Zanten on 08/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit
import SwiftyJSON
import CryptoSwift
import Logging
import secp256k1

// swiftlint:disable file_length
public class WalletClient: WalletClientProtocol {

    enum WalletClientError: Error {
        case addressToScriptError(address: Address)
        case invalidDeriver(value: String)
        case invalidMessageData(message: String)
        case invalidAddressReceived(address: Vws.AddressInfo?)
        case noOutputFound
        case noSigningKeyFound(path: String, address: String)
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

    func currentCopayerId() -> String {
        if let stored = self.applicationRepository.copayerId, !stored.isEmpty {
            return stored
        }

        return self.getCopayerId()
    }

    // MARK: Request methods

    private func getRequest(url: String, completion: @escaping URLCompletion) {
        let referencedUrl = url.addUrlReference()

        guard let url = URL(string: "\(baseUrl)\(referencedUrl)".urlify()) else {
            return completion(nil, nil, NSError(domain: "Wrong URL", code: 500))
        }

        do {
            let signature = try getSignature(url: referencedUrl, method: "get")
            let copayerId = self.currentCopayerId()
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(copayerId, forHTTPHeaderField: "x-identity")
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
            let copayerId = self.currentCopayerId()
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
//            request.setValue("bwc-8.1.1",forHTTPHeaderField: "x-client-version")
            request.setValue(copayerId, forHTTPHeaderField: "x-identity")
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
            let copayerId = self.currentCopayerId()
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
        let xPubKey = self.credentials.customExtendedPublicKey ?? self.credentials.publicKey.extended().description
        let hash = self.sjcl.sha256Hash(data: "xvg\(xPubKey)")

        return self.sjcl.hexFromBits(hash: hash)
    }
//    private func getCopayerId() -> String {
//        let xPubKey = self.credentials.bip32ExtenedPublicKey
//        let hash = self.sjcl.sha256Hash(data: "xvg\(xPubKey ?? "")")
//
//        return self.sjcl.hexFromBits(hash: hash)
//    }

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
print("create wallet--\(args)")
        self.postRequest(url: "/v2/wallets/", arguments: args) { data, _, error in
            if let jsonString = String(data: data!, encoding: .utf8) { print("create wallet response: \(jsonString)") }
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
        // MARK: - Safe keys to send
     //   let xPubKey = self.credentials.publicKey.extended()
//        let xPubKey = self.credentials.bip32ExtenedPublicKey ?? ""
        let xPubKey = self.credentials.customExtendedPublicKey ?? ""
        
//        if let xPubKey = credentials.xPubKey {
//            print("xPubKey: \(xPubKey)")
//        }
//        credentials.printAllKeys()
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

        // POST request to join wallet
        self.postRequest(url: "/v2/wallets/\(walletIdentifier)/copayers/", arguments: arguments) { data, _, error in
            print("wallet join arguments--\(arguments)")
            guard let data = data else {
                print("error---\(error)")
                return completion(nil, nil, error)
            }

            do {
                if let jsonString = String(data: data, encoding: .utf8) { print("Raw wallet join response: \(jsonString)") }

                let walletJoin = try JSONDecoder().decode(Vws.WalletJoin.self, from: data)

                completion(walletJoin, nil, nil)
            } catch {
                // Try to decode server-side WalletJoin error
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
        self.postRequest(url: "/v4/addresses/", arguments: nil) { data, response, error in
            guard let data = data else {
                return completion(error, nil, nil)
            }

            if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                self.log.notice("wallet client create address returned non-success status", metadata: [
                    "status": Logger.MetadataValue(stringLiteral: "\(httpResponse.statusCode)"),
                    "response": Logger.MetadataValue(stringLiteral: String(data: data, encoding: .utf8) ?? "")
                ])
            }

            do {
                let decoder = JSONDecoder()
                let addressInfo: Vws.AddressInfo

                do {
                    addressInfo = try decoder.decode(Vws.AddressInfo.self, from: data)
                } catch {
                    addressInfo = try decoder.decode(Vws.AddressWrappedResponse.self, from: data).address
                }

                // Make sure the received address is really your address.
//                let addressByPath = try self.credentials.privateKeyBy(
//                    path: addressInfo.path,
//    privateKey: self.credentials.bip44PrivateKey
//                ).publicKey().toLegacy().description
                if !addressInfo.path.isEmpty {
                    do {
                        let hdPrivateKey = try self.credentials.privateKeyBy(
                            path: addressInfo.path,
                            privateKey: self.credentials.bip44PrivateKey
                        )
                        let hdPublicKey = hdPrivateKey.publicKey()
                        let bitcoinPubKey = PublicKey(bytes: hdPublicKey.data, network: .mainnetXVG)
                        let legacyAddress = bitcoinPubKey.toBitcoinAddress()

                        print("Legacy Address: \(legacyAddress)")
                    } catch {
                        self.log.notice("wallet client skipped local address verification", metadata: [
                            "error": Logger.MetadataValue(stringLiteral: error.localizedDescription),
                            "path": Logger.MetadataValue(stringLiteral: addressInfo.path)
                        ])
                    }
                }

//                if addressInfo.address != legacyAddress.description {
//                    return completion(WalletClientError.invalidAddressReceived(address: addressInfo), nil, nil)
//                }

                completion(nil, addressInfo, nil)
            } catch {
                let errorResponse = try? JSONDecoder().decode(Vws.CreateAddressError.self, from: data)
                self.log.error("wallet client failed to decode create address response", metadata: [
                    "error": Logger.MetadataValue(stringLiteral: error.localizedDescription),
                    "response": Logger.MetadataValue(stringLiteral: String(data: data, encoding: .utf8) ?? "")
                ])

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

        self.getRequest(url: "/v1/addresses/\(qs)") { data, response, error in
            guard let data = data else {
                return completion(error, [])
            }

            if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                self.log.notice("wallet client get addresses returned non-success status", metadata: [
                    "status": Logger.MetadataValue(stringLiteral: "\(httpResponse.statusCode)"),
                    "response": Logger.MetadataValue(stringLiteral: String(data: data, encoding: .utf8) ?? "")
                ])

                return completion(nil, [])
            }

            do {
                let decoder = JSONDecoder()

                do {
                    completion(nil, try decoder.decode([Vws.AddressInfo].self, from: data))
                } catch {
                    completion(nil, try decoder.decode(Vws.AddressResponse.self, from: data).addresses)
                }
            } catch {
                self.log.notice("wallet client failed to decode get addresses response; creating a new address instead", metadata: [
                    "error": Logger.MetadataValue(stringLiteral: error.localizedDescription),
                    "response": Logger.MetadataValue(stringLiteral: String(data: data, encoding: .utf8) ?? "")
                ])

                completion(nil, [])
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
        
        let copayerId = self.currentCopayerId()

        if referencedUrl.contains("/v1/balance/") {
            let signature = try self.getSignature(url: referencedUrl, method: "get")

            result.url = url
            result.copayerId = copayerId
            result.signature = signature
        }

        return result
    }

}

extension WalletClient.WalletClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .addressToScriptError(let address):
            return "Could not create a transaction script for address \(address.description)."
        case .invalidDeriver(let value):
            return "The wallet derivation path is invalid: \(value)."
        case .invalidMessageData(let message):
            return "Could not sign wallet service message: \(message)."
        case .invalidAddressReceived(let addressInfo):
            let address = addressInfo?.address ?? "unknown"
            return "The wallet service returned an invalid address: \(address)."
        case .noOutputFound:
            return "The wallet service returned a transaction proposal without a spend output."
        case .noSigningKeyFound(let path, let address):
            return "No signing key was found for input \(path) at address \(address)."
        }
    }
}

// MARK: Tx proposals methods

extension WalletClient {

    typealias TxProposalCompletion = (
        _ txp: Vws.TxProposalResponse?,
        _ errorResponse: Vws.TxProposalErrorResponse?,
        _ error: Error?
    ) -> Void

    private struct VergeUnsignedTransaction {
        let tx: Transaction
        let utxos: [UnspentTransaction]
        let timestamp: UInt32?
        let inputPaths: [String]
        let inputAddresses: [String]
        let inputPublicKeys: [[String]]
    }

    private struct WrappedTxProposalResponse: Decodable {
        let txp: Vws.TxProposalResponse?
        let txProposal: Vws.TxProposalResponse?
    }

    private struct TxProposalDecodeError: LocalizedError {
        let stage: String
        let underlying: Error

        var errorDescription: String? {
            return "VWS \(stage) response decode failed: \(Self.describe(underlying))"
        }

        private static func describe(_ error: Error) -> String {
            guard case let DecodingError.keyNotFound(key, context) = error else {
                return error.localizedDescription
            }

            let codingPath = context.codingPath.map { $0.stringValue }.joined(separator: ".")
            let path = codingPath.isEmpty ? "root" : codingPath

            return "missing key '\(key.stringValue)' at \(path)"
        }
    }

    private func decodeTxProposalResponse(
        from data: Data,
        stage: String,
        fallback txp: Vws.TxProposalResponse? = nil
    ) throws -> Vws.TxProposalResponse {
        let decoder = JSONDecoder()

        do {
            let response = try decoder.decode(Vws.TxProposalResponse.self, from: data)
            if let txp = txp {
                return mergeTxProposalResponse(response, into: txp)
            }
            return response
        } catch {
            do {
                let wrapped = try decoder.decode(WrappedTxProposalResponse.self, from: data)
                if let response = wrapped.txp ?? wrapped.txProposal {
                    if let txp = txp {
                        return mergeTxProposalResponse(response, into: txp)
                    }
                    return response
                }
            } catch {
                // Keep the original root decode failure; it usually has the useful missing-key path.
            }

            if (try? decoder.decode(Vws.TxProposalErrorResponse.self, from: data)) != nil {
                throw TxProposalDecodeError(stage: stage, underlying: error)
            }

            if let txp = txp {
                guard let partial = self.mergePartialTxProposalResponse(from: data, into: txp) else {
                    return txp
                }

                return partial
            }

            throw TxProposalDecodeError(stage: stage, underlying: error)
        }
    }

    private func mergeTxProposalResponse(
        _ response: Vws.TxProposalResponse,
        into txp: Vws.TxProposalResponse
    ) -> Vws.TxProposalResponse {
        return Vws.TxProposalResponse(
            createdOn: response.createdOn ?? txp.createdOn,
            coin: response.coin,
            id: response.id,
            network: response.network,
            message: response.message ?? txp.message,
            inputs: response.inputs.isEmpty ? txp.inputs : response.inputs,
            fee: response.fee,
            status: response.status,
            creatorId: response.creatorId,
            walletN: response.walletN,
            walletM: response.walletM,
            outputs: response.outputs.isEmpty ? txp.outputs : response.outputs,
            amount: response.amount == 0 ? txp.amount : response.amount,
            changeAddress: response.changeAddress,
            walletId: response.walletId,
            requiredSignatures: response.requiredSignatures,
            version: response.version,
            excludeUnconfirmedUtxos: response.excludeUnconfirmedUtxos,
            addressType: response.addressType,
            requiredRejections: response.requiredRejections,
            outputOrder: response.outputOrder.isEmpty ? txp.outputOrder : response.outputOrder,
            inputPaths: response.inputPaths.isEmpty ? txp.inputPaths : response.inputPaths
        )
    }

    private func mergePartialTxProposalResponse(
        from data: Data,
        into txp: Vws.TxProposalResponse
    ) -> Vws.TxProposalResponse? {
        let json = JSON(data)
        let response = json["txp"].exists() ? json["txp"] : json
        let status = response["status"].string ?? txp.status

        guard response["status"].exists() || response["txid"].exists() || response["broadcastedOn"].exists() else {
            return nil
        }

        return Vws.TxProposalResponse(
            createdOn: txp.createdOn,
            coin: txp.coin,
            id: response["id"].string ?? txp.id,
            network: txp.network,
            message: txp.message,
            inputs: txp.inputs,
            fee: txp.fee,
            status: status,
            creatorId: txp.creatorId,
            walletN: txp.walletN,
            walletM: txp.walletM,
            outputs: txp.outputs,
            amount: txp.amount,
            changeAddress: txp.changeAddress,
            walletId: txp.walletId,
            requiredSignatures: txp.requiredSignatures,
            version: txp.version,
            excludeUnconfirmedUtxos: txp.excludeUnconfirmedUtxos,
            addressType: txp.addressType,
            requiredRejections: txp.requiredRejections,
            outputOrder: txp.outputOrder,
            inputPaths: txp.inputPaths
        )
    }

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
                    return completion(try self.decodeTxProposalResponse(from: data, stage: "create transaction"), nil, nil)
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

            let transactionHash = serializeTransaction(unsignedTx.tx, timestamp: unsignedTx.timestamp).hex

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
                        return completion(
                            try self.decodeTxProposalResponse(from: data, stage: "publish transaction", fallback: txp),
                            nil,
                            nil
                        )
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
            let signatures = try signTx(unsignedTx: unsignedTx, keys: try privateKeys(for: txp), includeTimestamp: true)

            postSignatures(signatures, txp: txp) { txpResponse, errorResponse, error in
                guard errorResponse?.error == .BadSignatures else {
                    return completion(txpResponse, errorResponse, error)
                }

                do {
                    let legacySignatures = try self.signTx(
                        unsignedTx: unsignedTx,
                        keys: try self.privateKeys(for: txp),
                        includeTimestamp: false
                    )
                    self.postSignatures(legacySignatures, txp: txp, completion: completion)
                } catch {
                    completion(nil, nil, error)
                }
            }
        } catch {
            completion(nil, nil, error)
        }
    }

    private func privateKeys(for txp: Vws.TxProposalResponse) throws -> [PrivateKey] {
        var keys = [PrivateKey]()
        var seen = Set<String>()
        let roots = [
            credentials.legacyVwsBip44PrivateKey,
            credentials.bip44PrivateKey,
            credentials.walletPrivateKey1,
            credentials.privateKey1
        ]

        for output in txp.inputs {
            for root in roots {
                do {
                    let key = try credentials.privateKeyBy(path: output.path, privateKey: root)
                    let candidates = [
                        key,
                        PrivateKey(
                            data: key.data,
                            network: .mainnetXVG,
                            isPublicKeyCompressed: false
                        )
                    ]

                    for candidate in candidates {
                        let id = "\(candidate.data.hex):\(candidate.isPublicKeyCompressed)"
                        guard !seen.contains(id) else {
                            continue
                        }

                        keys.append(candidate)
                        seen.insert(id)
                    }
                } catch {
                    self.log.notice("wallet client skipped signing key candidate", metadata: [
                        "path": Logger.MetadataValue(stringLiteral: output.path),
                        "error": Logger.MetadataValue(stringLiteral: error.localizedDescription)
                    ])
                }
            }
        }

        return keys
    }

    private func postSignatures(
        _ signatures: [String],
        txp: Vws.TxProposalResponse,
        completion: @escaping TxProposalCompletion
    ) {
        var arguments = JSON()
        arguments["signatures"] = JSON(signatures)

        postRequest(
            url: "/v1/txproposals/\(txp.id)/signatures/",
            arguments: arguments
        ) { data, _, error in
            if let data = data {
                do {
                    return completion(
                        try self.decodeTxProposalResponse(from: data, stage: "sign transaction", fallback: txp),
                        nil,
                        nil
                    )
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

    func broadcastTxProposal(txp: Vws.TxProposalResponse, completion: @escaping TxProposalCompletion) {
        postRequest(
            url: "/v1/txproposals/\(txp.id)/broadcast/",
            arguments: nil
        ) { data, _, error in
            if let data = data {
                do {
                    return completion(
                        try self.decodeTxProposalResponse(from: data, stage: "broadcast transaction", fallback: txp),
                        nil,
                        nil
                    )
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
        getRequest(url: "/v2/txproposals/") { data, response, error in
            if let error = error {
                return completion([], error)
            }

            guard let data = data else {
                return completion([], nil)
            }

            if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
                self.log.notice("wallet client tx proposals request returned non-success status", metadata: [
                    "status": Logger.MetadataValue(stringLiteral: "\(httpResponse.statusCode)"),
                    "response": Logger.MetadataValue(stringLiteral: String(data: data, encoding: .utf8) ?? "")
                ])

                return completion([], nil)
            }

            do {
                let txps = try JSONDecoder().decode([Vws.TxProposalResponse].self, from: data)

                completion(txps, nil)
            } catch {
                self.log.notice("wallet client tx proposals response was not a proposal array", metadata: [
                    "error": Logger.MetadataValue(stringLiteral: error.localizedDescription),
                    "response": Logger.MetadataValue(stringLiteral: String(data: data, encoding: .utf8) ?? "")
                ])

                completion([], nil)
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

    private func signMessage(_ message: String, privateKey: HDPrivateKey1) throws -> String {
        guard let messageData = message.data(using: .utf8) else {
            throw WalletClientError.invalidMessageData(message: message)
        }

        // Electrum / Bitcore uses SINGLE SHA-256 (not double)
        let hash = Crypto.sha256(messageData)

        // Compact 64-byte signature
        let compact = try Crypto.sign(hash, privateKey: privateKey.privateKey())

        // Convert to DER
        let der = try convertCompactToDER(compact)

        return der.hex
    }


    private func encryptMessage(plaintext: String, encryptingKey: String) -> String {
        let key = sjcl.base64ToBits(encryptingKey: encryptingKey)

        return sjcl.encrypt(password: key, plaintext: plaintext, params: ["ks": 128, "iter": 1])
    }

    private func decryptMessage(ciphertext: String, encryptingKey: String) -> String {
        let key = sjcl.base64ToBits(encryptingKey: encryptingKey)

        return sjcl.decrypt(password: key, ciphertext: ciphertext, params: [])
    }

    private func getUnsignedTx(txp: Vws.TxProposalResponse) throws -> VergeUnsignedTransaction {
        guard let output = txp.outputs.first else {
            throw WalletClientError.noOutputFound
        }

        let changeAddress: Address = try self.createAddress(txp.changeAddress.address)
        let toAddress: Address = try self.createAddress(output.toAddress)

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
            inputs: unsignedInputs,
            outputs: outputs,
            lockTime: 0
        )

        return VergeUnsignedTransaction(
            tx: tx,
            utxos: unspentTransactions,
            timestamp: txp.createdOn,
            inputPaths: unspentOutputs.map { $0.path },
            inputAddresses: unspentOutputs.map { $0.address },
            inputPublicKeys: unspentOutputs.map { $0.publicKeys }
        )
    }

    private func signTx(
        unsignedTx: VergeUnsignedTransaction,
        keys: [PrivateKey],
        includeTimestamp: Bool
    ) throws -> [String] {
        let inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(
                version: unsignedTx.tx.version,
                inputs: inputsToSign,
                outputs: unsignedTx.tx.outputs,
                lockTime: unsignedTx.tx.lockTime
            )
        }

        var hexes = [String]()
        // Signing
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)
            let publicKeys = unsignedTx.inputPublicKeys.indices.contains(i)
                ? Set(unsignedTx.inputPublicKeys[i].map { $0.lowercased() })
                : Set<String>()

            let keysOfUtxo: [PrivateKey] = keys.filter { key in
                let publicKey = key.publicKey()
                return publicKey.pubkeyHash == pubkeyHash
                    || publicKeys.contains(publicKey.description.lowercased())
            }
            guard let key = keysOfUtxo.first else {
                throw WalletClientError.noSigningKeyFound(
                    path: unsignedTx.inputPaths.indices.contains(i) ? unsignedTx.inputPaths[i] : "",
                    address: unsignedTx.inputAddresses.indices.contains(i) ? unsignedTx.inputAddresses[i] : ""
                )
            }

            let sighash = signatureHash(
                transactionToSign,
                timestamp: includeTimestamp ? unsignedTx.timestamp : nil,
                for: utxo.output,
                inputIndex: i,
                hashType: SighashType.BTC.ALL
            )

            let signature: Data = try convertCompactToDER(signDigest(sighash, privateKey: key))

            hexes.append(signature.hex)
        }

        return hexes
    }

    private func serializeTransaction(_ transaction: Transaction, timestamp: UInt32?) -> Data {
        var data = Data()
        data += transaction.version.data
        if let timestamp = timestamp {
            data += timestamp.data
        }
        data += transaction.txInCount.serialized()
        data += transaction.inputs.flatMap { $0.serialized() }
        data += transaction.txOutCount.serialized()
        data += transaction.outputs.flatMap { $0.serialized() }
        data += transaction.lockTime.data
        return data
    }

    private func signatureHash(
        _ transaction: Transaction,
        timestamp: UInt32?,
        for utxoOutput: TransactionOutput,
        inputIndex: Int,
        hashType: SighashType.BTC
    ) -> Data {
        let helper = BTCSignatureHashHelper(hashType: hashType)
        guard inputIndex < transaction.inputs.count else {
            return helper.one
        }

        guard !(hashType.isSingle && inputIndex < transaction.outputs.count) else {
            return helper.one
        }

        let rawTransaction = Transaction(
            version: transaction.version,
            inputs: helper.createInputs(of: transaction, for: utxoOutput, inputIndex: inputIndex),
            outputs: helper.createOutputs(of: transaction, inputIndex: inputIndex),
            lockTime: transaction.lockTime
        )
        var data = serializeTransaction(rawTransaction, timestamp: timestamp)
        data += hashType.uint32.data

        return Crypto.sha256sha256(data)
    }

    private func signDigest(_ digest: Data, privateKey: PrivateKey) throws -> Data {
        guard digest.count == 32 else {
            throw NSError(
                domain: "SignatureError",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Transaction digest must be 32 bytes"]
            )
        }

        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
            throw NSError(
                domain: "SignatureError",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Could not create secp256k1 signing context"]
            )
        }
        defer { secp256k1_context_destroy(context) }

        var signature = secp256k1_ecdsa_signature()
        let signResult = digest.withUnsafeBytes { digestPtr in
            privateKey.data.withUnsafeBytes { privateKeyPtr in
                secp256k1_ecdsa_sign(
                    context,
                    &signature,
                    digestPtr.bindMemory(to: UInt8.self).baseAddress!,
                    privateKeyPtr.bindMemory(to: UInt8.self).baseAddress!,
                    nil,
                    nil
                )
            }
        }

        guard signResult == 1 else {
            throw NSError(
                domain: "SignatureError",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Could not sign transaction digest"]
            )
        }

        var compactSignature = Data(repeating: 0, count: 64)
        compactSignature.withUnsafeMutableBytes { signaturePtr in
            secp256k1_ecdsa_signature_serialize_compact(
                context,
                signaturePtr.bindMemory(to: UInt8.self).baseAddress!,
                &signature
            )
        }

        return compactSignature
    }

    // Converts 64-byte compact (r||s) ECDSA signature → DER format
    func convertCompactToDER(_ compactSig: Data) throws -> Data {
        guard compactSig.count == 64 else {
            throw NSError(domain: "SignatureError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Compact signature must be 64 bytes"])
        }

        let r = Data(compactSig.prefix(32))
        let s = Data(compactSig.suffix(32))
        let derR = derInt(r)
        let derS = derInt(s)
        var sequence = Data()
        sequence.append(contentsOf: derR)
        sequence.append(contentsOf: derS)
        var der = Data()
        der.append(0x30)
        der.append(UInt8(sequence.count))
        der.append(sequence)

        return der
    }
    func derInt(_ data: Data) -> Data {
        var raw = Data(data)
        
        // Remove leading zeros, but keep at least 1 byte
        while raw.count > 1 && raw.first == 0 {
            raw.removeFirst()
        }

        // If MSB is 1, prepend 0x00
        if let first = raw.first, first & 0x80 != 0 {
            raw = Data([0x00]) + raw
        }

        var result = Data([0x02]) // INTEGER tag

        // DER length encoding
        if raw.count < 0x80 {
            result.append(UInt8(raw.count))
        } else {
            let lengthBytes = withUnsafeBytes(of: UInt32(raw.count).bigEndian) {
                Data($0).drop { $0 == 0 }
            }
            result.append(UInt8(0x80 | lengthBytes.count))
            result.append(lengthBytes)
        }

        result.append(raw)
        return result
    }

    private func createAddress(_ plainAddress: String) throws -> Address {
        do {
            return try AddressFactory.create(plainAddress)
        } catch {
            guard let payload = Base58Check.decode(plainAddress), payload.count == 21 else {
                throw error
            }

            let versionByte = payload[0]
            let hashType: BitcoinAddress.HashType

            switch versionByte {
            case Network.mainnetXVG.pubkeyhash:
                hashType = .pubkeyHash
            case Network.mainnetXVG.scripthash:
                hashType = .scriptHash
            default:
                throw error
            }

            return try BitcoinAddress(
                data: payload.dropFirst(),
                hashType: hashType,
                network: .mainnetXVG
            )
        }
    }

}
// swiftlint:enable file_length
