//
//  CurrencyInput.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/11/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class CurrencyInput: UITextField {

    fileprivate let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = Constants.maximumFractionDigits

        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)
    }
    
    @objc public func editingChanged(_ textField: UITextField) {
        handleFormatting()
    }
    
    @objc public func editingDidEnd(_ textField: UITextField) {
        if getNumber().doubleValue == 0.0 {
            textField.text = ""
            return
        }

        // Final Format.
        setAmount(getNumber())
    }

    public func getNumber() -> NSNumber {
        guard var text = self.text else {
            return NSNumber(value: 0.0)
        }

        // Remove grouping separators
        // Replace the decimal separator for a dot.
        text = text
            .replacingOccurrences(of: formatter.groupingSeparator, with: "")
            .replacingOccurrences(of: formatter.decimalSeparator, with: ".")

        let format = NumberFormatter()
        format.locale = Locale(identifier: "en_US")
        format.numberStyle = .decimal

        return format.number(from: text) ?? NSNumber()
    }

    public func setAmount(_ amount: NSNumber) {
        text = amount.toBlankCurrency(fractDigits: Constants.maximumFractionDigits)
        text = text?.replacingOccurrences(of: " ", with: "")

        format()
    }

    public func format() {
        handleFormatting()

        // If the value is nothing we empty the field.
        if getNumber().doubleValue == 0.0 {
            text = ""
        }

        // Make sure the value is always displayed with two decimals after the separator.
        if let dotIndex = text?.index(of: formatter.decimalSeparator) {
            let minimumLength = dotIndex.encodedOffset + 3
            let wantedLength = text!.count >= minimumLength ? text!.count : minimumLength

            text = text?.padding(toLength: wantedLength, withPad: "0", startingAt: 0)
        }
    }

    private func handleFormatting() {
        guard var text = self.text else {
            return
        }

        // If the last character isn't a number we remove it and add the decimal separator.
        if text.last?.description != nil && !CharacterSet.decimalDigits.isSuperset(
            of: CharacterSet(charactersIn: text.last!.description)
        ) {
            text.removeLast()
            text = "\(text)\(formatter.decimalSeparator.description)"
        }

        text = text.replacingOccurrences(of: formatter.groupingSeparator, with: "")

        // Get the text before the added character.
        let previousText = text.dropLast().description

        // If the last character is an decimal separator and there is already one we remove it.
        if text.last?.description == formatter.decimalSeparator && previousText.contains(formatter.decimalSeparator) {
            text.removeLast()
        }

        // If the first character is a decimal separator... add a zero.
        if text.first?.description == formatter.decimalSeparator {
            text = "0\(text)"
        }

        // Group the numbers above the decimal separator.
        var counted = 0
        var newText = ""
        let includesDecimalSeparator = String(text).contains(formatter.decimalSeparator)

        for number in String(text).reversed() {
            if includesDecimalSeparator && !newText.contains(formatter.decimalSeparator) {
                newText.insert(number, at: String.Index.init(encodedOffset: 0))
                continue
            }

            if counted == formatter.groupingSize {
                newText.insert(Character(formatter.groupingSeparator), at: String.Index.init(encodedOffset: 0))
                counted = 0
            }

            newText.insert(number, at: String.Index.init(encodedOffset: 0))
            counted += 1
        }

        self.text = newText
    }
}

extension StringProtocol where Index == String.Index {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
}
