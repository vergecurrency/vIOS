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

   
    static func validate(address: String) -> Bool {
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



    func validate(
        metadataObject: AVMetadataMachineReadableCodeObject,
        completion: @escaping ValidationCompletion
    ) {
        validate(string: metadataObject.stringValue ?? "", completion: completion)
    }

    func validate(string: String, completion: @escaping ValidationCompletion) {
        var valid = false
        var address: String?
        var amount: NSNumber?
        var label: String?
        var currency: String?

        let parameters = self.normalizeUrl(url: string)

        guard let addressParam = parameters["address"], AddressValidator.validate(address: addressParam ?? "") else {
            return completion(valid, address, amount, label, currency)
        }

        address = addressParam
        valid = true

        if let amountParam = parameters["amount"], amountParam != nil {
            amount = self.amountToNumber(stringAmount: amountParam!)
        }

        if let labelParam = parameters["label"], labelParam != nil {
            label = labelParam!.removingPercentEncoding
        }

        if let currencyParam = parameters["currency"] {
            currency = currencyParam?.uppercased() == "XVG" ? nil : currencyParam
        }

        completion(valid, address, amount, label, currency)
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
}
