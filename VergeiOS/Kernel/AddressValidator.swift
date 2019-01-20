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

class AddressValidator {
    
    typealias ValidationCompletion = (_ valid: Bool, _ address: String?, _ amount: NSNumber?) -> Void

    static func validate(address: String) -> Bool {
        let validAddress = try? LegacyAddress(address)

        return validAddress != nil
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
        
        if AddressValidator.validate(address: string) {
            valid = true
            address = string
        }

        let splittedRequest: [Substring] = string
            .replacingOccurrences(of: "verge://", with: "")
            .replacingOccurrences(of: "verge:", with: "")
            .split(separator: "?")

        let parametersString: [Substring] = splittedRequest.last?.split(separator: "&") ?? []

        if AddressValidator.validate(address: splittedRequest.first?.description ?? "") {
            valid = true
            address = splittedRequest.first!.description
        } else {
            return completion(valid, address, amount)
        }
        
        let splittedParameters = parametersString.last?.split(separator: "&") ?? []
        var parameters = [String: String]()
        
        for param in splittedParameters {
            let splittedParam = param.split(separator: "=")
            parameters[splittedParam.first!.description] = splittedParam.last!.description
        }
        
        if let amountParam = parameters["amount"] {
            amount = amountToNumber(stringAmount: amountParam)
        }
        
        completion(valid, address, amount)
    }
    
    fileprivate static func regexMatches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(
                in: text,
                range: NSRange(text.startIndex..., in: text)
            )
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    fileprivate func amountToNumber(stringAmount: String) -> NSNumber? {
        if let double = Double(stringAmount) {
            return NSNumber(value: double)
        }
        
        return nil
    }
}
