//
//  BitcoreNodeClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import SwiftyJSON
import Logging
import Promises

class BitcoreNodeClient: BitcoreNodeClientProtocol {
    enum Error: Swift.Error {
        case invalidUrl(url: String)
        case txNotAccepted(rawTx: String)
        case noDataReturned
    }

    typealias URLCompletion = (Data?, URLResponse?, Swift.Error?) -> Void

    private let baseUrl: String
    private let httpSession: HttpSessionProtocol
    private let log: Logger

    init(baseUrl: String, httpSession: HttpSessionProtocol, log: Logger) {
        self.baseUrl = baseUrl
        self.httpSession = httpSession
        self.log = log
    }

    func send(rawTx: String) -> Promise<Bn.SendResponse> {
        var body = JSON()
        body["rawTx"].stringValue = rawTx

        return Promise { fulfill, reject in
            try self.postRequest(url: "/tx/send", body: body) { data, _, error in
                guard let data = data else {
                    return reject(error ?? Error.noDataReturned)
                }

                do {
                    fulfill(try JSONDecoder().decode(Bn.SendResponse.self, from: data))
                } catch {
                    self.log.error("bitcore node client error decoding send response: \(error.localizedDescription)")

                    reject(Error.txNotAccepted(rawTx: rawTx))
                }
            }
        }
    }

    func block(byHash hash: String) -> Promise<Bn.Block> {
        return Promise { fulfill, reject in
            try self.getRequest(url: "/block/\(hash)") { data, _, error in
                guard let data = data else {
                    return reject(error ?? Error.noDataReturned)
                }

                do {
                    fulfill(try JSONDecoder().decode(Bn.Block.self, from: data))
                } catch {
                    self.log.error("bitcore node client error decoding bloack: \(error.localizedDescription)")

                    reject(error)
                }
            }
        }
    }

    func transactions(byAddress address: String) -> Promise<[Bn.Transaction]> {
        return Promise { fulfill, reject in
            try self.getRequest(url: "/address/\(address)/txs") { data, _, error in
                guard let data = data else {
                    return reject(error ?? Error.noDataReturned)
                }

                do {
                    fulfill(try JSONDecoder().decode([Bn.Transaction].self, from: data))
                } catch {
                    self.log.error("bitcore node client error decoding transactions: \(error.localizedDescription)")

                    reject(error)
                }
            }
        }
    }

    func unspendTransactions(byAddress address: String) -> Promise<[Bn.Transaction]> {
        return Promise { fulfill, reject in
            try self.getRequest(url: "/address/\(address)/?unspent=true") { data, _, error in
                guard let data = data else {
                    return reject(error ?? Error.noDataReturned)
                }

                do {
                    fulfill(try JSONDecoder().decode([Bn.Transaction].self, from: data))
                } catch {
                    self.log.error("bitcore node client error decoding transactions: \(error.localizedDescription)")

                    reject(error)
                }
            }
        }
    }

    func balance(byAddress address: String) -> Promise<Bn.Balance> {
        return Promise { fulfill, reject in
            try self.getRequest(url: "/address/\(address)/balance") { data, _, error in
                guard let data = data else {
                    return reject(error ?? Error.noDataReturned)
                }

                do {
                    fulfill(try JSONDecoder().decode(Bn.Balance.self, from: data))
                } catch {
                    self.log.error("bitcore node client error decoding balance: \(error.localizedDescription)")

                    reject(error)
                }
            }
        }
    }

    private func getRequest(url: String, completion: @escaping URLCompletion) throws {
        guard let urlObject = URL(string: "\(self.baseUrl)\(url)") else {
            throw Error.invalidUrl(url: url)
        }

        var request = URLRequest(url: urlObject)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")

        self.log(request: request)
        self.request(request, completion: completion)
    }

    private func postRequest(url: String, body: JSON, completion: @escaping URLCompletion) throws {
        guard let urlObject = URL(string: "\(self.baseUrl)\(url)") else {
            throw Error.invalidUrl(url: url)
        }

        var request = URLRequest(url: urlObject)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try! body.rawData()

        self.log(request: request)
        self.request(request, completion: completion)
    }

    private func request(_ request: URLRequest, completion: @escaping URLCompletion) {
        self.httpSession.dataTask(with: request).then { response in
            completion(response.data, response.urlResponse, nil)
        }.catch { error in
            self.log.error("bitcore node client request error: \(error.localizedDescription)")

            completion(nil, nil, error)
        }
    }

    private func log(request: URLRequest) {
        self.log.info("bitcore node client request fired", metadata: [
            "method": Logger.MetadataValue(stringLiteral: request.httpMethod ?? ""),
            "url": Logger.MetadataValue(stringLiteral: request.url?.absoluteString ?? "")
        ])
    }
}
