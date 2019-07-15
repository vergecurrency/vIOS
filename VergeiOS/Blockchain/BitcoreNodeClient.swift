//
//  BitcoreNodeClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import SwiftyJSON

class BitcoreNodeClient: BitcoreNodeClientProtocol {
    enum BitcoreNodeClientError: Error {
        case invalidUrl(url: String)
    }

    let baseUrl: String!
    let torClient: TorClient!

    init(baseUrl: String, torClient: TorClient) {
        self.baseUrl = baseUrl
        self.torClient = torClient
    }

    func send(rawTx: String, completion: @escaping SendCompletion) {
        var body = JSON()
        body["rawTx"].stringValue = rawTx

        try? self.postRequest(url: "/tx/send", body: body) { data, _, error in
            guard let data = data else {
                return completion(nil, nil)
            }

            completion(error, try? JSONDecoder().decode(BNSendResponse.self, from: data))
        }
    }

    func block(byHash hash: String, completion: @escaping BlockCompletion) {
        try? self.getRequest(url: "/block/\(hash)") { data, _, error in
            guard let data = data else {
                return completion(nil, nil)
            }

            completion(error, try? JSONDecoder().decode(BNBlock.self, from: data))
        }
    }

    func transactions(byAddress address: String, completion: @escaping TransactionCompletion) {
        try? self.getRequest(url: "/address/\(address)/txs") { data, _, error in
            guard let data = data else {
                return completion(nil, [])
            }

            let transactions = try? JSONDecoder().decode([BNTransaction].self, from: data)

            completion(error, transactions ?? [])
        }
    }

    func unspendTransactions(byAddress address: String, completion: @escaping TransactionCompletion) {
        try? self.getRequest(url: "/address/\(address)/?unspent=true") { data, _, error in
            guard let data = data else {
                return completion(nil, [])
            }

            let transactions = try? JSONDecoder().decode([BNTransaction].self, from: data)

            completion(error, transactions ?? [])
        }
    }

    func balance(byAddress address: String, completion: @escaping BalanceCompletion) {
        try? self.getRequest(url: "/address/\(address)/balance") { data, _, error in
            guard let data = data else {
                return completion(nil, nil)
            }

            completion(error, try? JSONDecoder().decode(BNBalance.self, from: data))
        }
    }

    private func getRequest(url: String, completion: @escaping URLCompletion) throws {
        guard let urlObject = URL(string: "\(self.baseUrl!)\(url)") else {
            throw BitcoreNodeClientError.invalidUrl(url: url)
        }

        var request = URLRequest(url: urlObject)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        print("Get request to: \(urlObject.absoluteURL)")
        
        let task = self.torClient.session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.sync {
                completion(data, response, error)
            }
        }

        DispatchQueue.main.async {
            task.resume()
        }
    }

    private func postRequest(url: String, body: JSON, completion: @escaping URLCompletion) throws {
        guard let urlObject = URL(string: "\(self.baseUrl!)\(url)") else {
            throw BitcoreNodeClientError.invalidUrl(url: url)
        }

        var request = URLRequest(url: urlObject)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try! body.rawData()
        print("Post request to: \(urlObject.absoluteURL)")

        let task = self.torClient.session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.sync {
                completion(data, response, error)
            }
        }

        DispatchQueue.main.async {
            task.resume()
        }
    }
}
