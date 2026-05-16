//
//  AddressValidator.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import AVFoundation
import BitcoinKit
//import BitcoinKit

class AddressValidator {
    typealias ValidationCompletion = (
        _ valid: Bool,
        _ address: String?,
        _ amount: NSNumber?,
        _ label: String?,
        _ currency: String?
    ) -> Void

    enum ResolutionError: Error {
        case missingApiToken
        case httpStatus(Int)
        case emptyResponse
        case noRecords
        case recordNotFound
        case invalidJson
        case invalidResolvedAddress
    }

    private enum UnstoppableDomains {
        static let apiBaseUrl = "https://api.unstoppabledomains.com/resolve/domains/"
        static let recordKey = "crypto.XVG.address"

        static var apiToken: String? {
            return Bundle.main.object(forInfoDictionaryKey: "UNSTOPPABLE_DOMAINS_API_TOKEN") as? String
        }

        static func looksLikeDomain(_ value: String) -> Bool {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

            return trimmed.firstIndex(of: ".") != nil
                && trimmed.firstIndex(of: ".") != trimmed.startIndex
                && !trimmed.contains(" ")
                && !trimmed.contains("://")
                && !trimmed.contains("/")
        }
    }

    private struct UnstoppableDomainsResponse: Decodable {
        let records: [String: String]?
    }

    static func validate(address: String) -> Bool {
        if validateVergeLegacy(address: address) {
            return true
        }

        // Try legacy first
        if let _ = try? BitcoinAddress(legacy: address) {
            return true
        }

        // Try cashaddr (if relevant)
        if let _ = try? BitcoinAddress(cashaddr: address) {
            return true
        }

        return false
    }

    private static func validateVergeLegacy(address: String) -> Bool {
        guard let payload = Base58Check.decode(address), payload.count == 21 else {
            return false
        }

        let versionByte = payload[0]

        return versionByte == Network.mainnetXVG.pubkeyhash
            || versionByte == Network.mainnetXVG.scripthash
    }



    func validate(
        metadataObject: AVMetadataMachineReadableCodeObject,
        completion: @escaping ValidationCompletion
    ) {
        validate(string: metadataObject.stringValue ?? "", completion: completion)
    }

    func validate(string: String, completion: @escaping ValidationCompletion) {
        validate(string: string, resolveDomains: false) { valid, address, amount, label, currency, _ in
            completion(valid, address, amount, label, currency)
        }
    }

    func validateOrResolve(string: String, completion: @escaping ValidationCompletion) {
        validateOrResolve(string: string) { valid, address, amount, label, currency, _ in
            completion(valid, address, amount, label, currency)
        }
    }

    func validateOrResolve(
        string: String,
        completion: @escaping (
            _ valid: Bool,
            _ address: String?,
            _ amount: NSNumber?,
            _ label: String?,
            _ currency: String?,
            _ error: ResolutionError?
        ) -> Void
    ) {
        validate(string: string, resolveDomains: true, completion: completion)
    }

    private func validate(
        string: String,
        resolveDomains: Bool,
        completion: @escaping (
            _ valid: Bool,
            _ address: String?,
            _ amount: NSNumber?,
            _ label: String?,
            _ currency: String?,
            _ error: ResolutionError?
        ) -> Void
    ) {
        var valid = false
        var address: String?
        var amount: NSNumber?
        var label: String?
        var currency: String?

        let parameters = self.normalizeUrl(url: string)
        let addressParam = parameters["address"] ?? nil

        guard let recipient = addressParam else {
            return completion(valid, address, amount, label, currency, nil)
        }

        if let amountParam = parameters["amount"], amountParam != nil {
            amount = self.amountToNumber(stringAmount: amountParam!)
        }

        if let labelParam = parameters["label"], labelParam != nil {
            label = labelParam!.removingPercentEncoding
        }

        if let currencyParam = parameters["currency"] {
            currency = currencyParam?.uppercased() == "XVG" ? nil : currencyParam
        }

        if AddressValidator.validate(address: recipient) {
            valid = true
            address = recipient

            return completion(valid, address, amount, label, currency, nil)
        }

        guard resolveDomains, UnstoppableDomains.looksLikeDomain(recipient) else {
            return completion(valid, address, amount, label, currency, nil)
        }

        resolveUnstoppableDomain(recipient) { result in
            switch result {
            case .success(let resolvedAddress):
                guard AddressValidator.validate(address: resolvedAddress) else {
                    return completion(false, nil, amount, label, currency, .invalidResolvedAddress)
                }

                completion(true, resolvedAddress, amount, label, currency, nil)
            case .failure(let error):
                completion(false, nil, amount, label, currency, error)
            }
        }
    }

    fileprivate func amountToNumber(stringAmount: String) -> NSNumber? {
        if let double = Double(stringAmount) {
            return NSNumber(value: double)
        }

        return nil
    }

    fileprivate func normalizeUrl(url: String) -> [String: String?] {
        let splittedRequest: [Substring] = url
            .replacingOccurrences(of: "verge://", with: "")
            .replacingOccurrences(of: "verge:", with: "")
            .replacingOccurrences(of: "https://tag.vergecurrency.business/", with: "")
            .split(separator: "?")

        let parametersString: [Substring] = splittedRequest.last?.split(separator: "&") ?? []
        var parameters = [String: String]()

        for param in parametersString {
            let splittedParam = param.split(separator: "=")
            parameters[splittedParam.first!.description] = splittedParam.last!.description
        }

        if (parameters.index(forKey: "address") == nil) {
            parameters["address"] = String(splittedRequest.first ?? "")
        }

        return parameters
    }

    private func resolveUnstoppableDomain(_ domain: String, completion: @escaping (Result<String, ResolutionError>) -> Void) {
        guard let token = UnstoppableDomains.apiToken, !token.isEmpty else {
            return completion(.failure(.missingApiToken))
        }

        let trimmedDomain = domain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let encodedDomain = trimmedDomain.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: UnstoppableDomains.apiBaseUrl + encodedDomain)
        else {
            return completion(.failure(.recordNotFound))
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.emptyResponse))
            }

            guard httpResponse.statusCode == 200 else {
                return completion(.failure(.httpStatus(httpResponse.statusCode)))
            }

            guard let data = data, !data.isEmpty else {
                return completion(.failure(.emptyResponse))
            }

            guard let decoded = try? JSONDecoder().decode(UnstoppableDomainsResponse.self, from: data) else {
                return completion(.failure(.invalidJson))
            }

            guard let records = decoded.records else {
                return completion(.failure(.noRecords))
            }

            guard let address = records[UnstoppableDomains.recordKey], !address.isEmpty else {
                return completion(.failure(.recordNotFound))
            }

            completion(.success(self.normalizedResolvedAddress(address)))
        }.resume()
    }

    private func normalizedResolvedAddress(_ address: String) -> String {
        return address
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "verge://", with: "")
            .replacingOccurrences(of: "verge:", with: "")
    }
}
