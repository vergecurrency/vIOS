//
//  Transaction.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 06-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

struct Transaction: Decodable {

    enum CodingKeys: String, CodingKey {
        case txid
        case vout
        case account
        case address
        case confirmations
        case blockhash
        case blockindex
        case blocktimeValue = "blocktime"
        case timeValue = "time"
        case timereceivedValue = "timereceived"
        case amountValue = "amount"
        case categoryValue = "category"
        case memo
    }

    public let txid: String
    public let vout: String
    public let account: String
    public let address: String
    public let confirmations: Int
    public let blockhash: String
    public let blockindex: Int
    public let memo: String?

    private var blocktimeValue: Double
    private var timeValue: Double
    private var timereceivedValue: Double
    private var amountValue: Double
    private var categoryValue: String

    var blocktime: Date {
        get {
            return Date(timeIntervalSince1970: TimeInterval(blocktimeValue))
        }
        set {
            blocktimeValue = newValue.timeIntervalSince1970.binade
        }
    }

    var time: Date {
        get {
            return Date(timeIntervalSince1970: TimeInterval(timeValue))
        }
        set {
            timeValue = newValue.timeIntervalSince1970.binade
        }
    }

    var timereceived: Date {
        get {
            return Date(timeIntervalSince1970: TimeInterval(timereceivedValue))
        }
        set {
            timereceivedValue = newValue.timeIntervalSince1970.binade
        }
    }

    var amount: NSNumber {
        get {
            return NSNumber(value: amountValue)
        }
        set {
            amountValue = newValue.doubleValue
        }
    }

    var category: TransactionType {
        get {
            return (categoryValue == "receive") ? .Received : .Send
        }
        set {
            categoryValue = (newValue == .Received) ? "receive" : "send"
        }
    }
}
