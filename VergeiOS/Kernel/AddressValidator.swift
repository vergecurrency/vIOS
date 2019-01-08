//
//  AddressValidator.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import AVFoundation

class AddressValidator {
    
    typealias ValidationCompletion = (_ valid: Bool, _ address: String?, _ amount: NSNumber?) -> Void
    
    static let addressRegex = "([a-z|A-Z|0-9]{34})"
    let requestRegex = "(verge:[\\/]{0,2}[a-z|A-Z|0-9]{34})|(\\?amount=\\d+[\\.|\\,]?\\d+)"
    let addressCount = 34
    
    func validate(
        metadataObject: AVMetadataMachineReadableCodeObject,
        completion: @escaping ValidationCompletion
    ) {
        validate(string: metadataObject.stringValue ?? "", completion: completion)
    }
    
    // Sugesstion: better to make it static.
    // No need to create AddressValidator each time to validate something like in contact model
    static func validate(address: String) -> Bool {
        let matches = regexMatches(for: addressRegex, in: address)
        if matches.indices.count > 0 && matches.indices.contains(0) {
            return true
        }
        return false
    }
    
    func validate(string: String, completion: @escaping ValidationCompletion) {
        var valid = false
        var address: String?
        var amount: NSNumber?
        
        if string.count == addressCount {
            valid = true
            address = string
        }
        
        let matches = AddressValidator.regexMatches(for: requestRegex, in: string)
        if matches.indices.count > 0 && matches.indices.contains(0) {
            valid = true
            address = matches[0]
                .replacingOccurrences(of: "verge://", with: "")
                .replacingOccurrences(of: "verge:", with: "")
                .replacingOccurrences(of: "?", with: "")
        }
        
        if matches.indices.count == 2 && matches.indices.contains(1) {
            amount = amountToNumber(
                stringAmount: matches[1]
                    .replacingOccurrences(of: "?", with: "")
                    .replacingOccurrences(of: "amount=", with: "")
            )
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
    
    fileprivate func amountToNumber(stringAmount: String?) -> NSNumber? {
        if stringAmount != nil, let double = Double(stringAmount!) {
            return NSNumber(value: double)
        }
        
        return nil
    }
}
