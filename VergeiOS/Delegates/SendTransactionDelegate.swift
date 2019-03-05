//
//  SendTransactionDelegate.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

protocol SendTransactionDelegate: class {
    func didChangeSendTransaction(_ transaction: TransactionFactory)
    func getSendTransaction() -> TransactionFactory
    func currentAmount() -> NSNumber
    func currentCurrency() -> String
}
