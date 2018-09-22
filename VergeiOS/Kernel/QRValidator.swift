//
//  QRValidator.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import AVFoundation

class QRValidator {
    let requestRegex = "(verge:\\/\\/[a-z|A-Z|0-9]{34}\\?)|(amount=\\d+[\\.|\\,]?\\d+)$"
    let addressCount = 34
    
    func validate(
        metadataObject: AVMetadataMachineReadableCodeObject,
        completion: @escaping (_ valid: Bool, _ address: String?, _ amount: NSNumber?
    ) -> Void) {
        var valid = false
        var address: String?
        var amount: NSNumber?
        
        if metadataObject.stringValue?.count == 34 {
            valid = true
            address = metadataObject.stringValue
        }
        
        let matches = regexMatches(for: requestRegex, in: metadataObject.stringValue ?? "")
        if matches.indices.count == 2 && matches.indices.contains(0) {
            valid = true
            address = matches[0]
                .replacingOccurrences(of: "verge://", with: "")
                .replacingOccurrences(of: "?", with: "")
        }
        
        if matches.indices.count == 2 && matches.indices.contains(1) {
            amount = amountToNumber(
                stringAmount: matches[1].replacingOccurrences(of: "amount=", with: "")
            )
        }
        
        completion(valid, address, amount)
    }
    
    func regexMatches(for regex: String, in text: String) -> [String] {
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
