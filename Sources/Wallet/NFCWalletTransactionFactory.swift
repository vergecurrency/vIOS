//
//  NFCWalletTransactionFactory.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/09/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import Logging
import CoreNFC

class NFCWalletTransactionFactory: NSObject, NFCNDEFReaderSessionDelegate {
    private let sendTransactionDelegate: SendTransactionDelegate
    private let addressValidator: AddressValidator
    private let logger: Logger

    private var detectedNfcMessages = [NFCNDEFMessage]()
    private var nfcSession: NFCNDEFReaderSession?

    init(
        sendTransactionDelegate: SendTransactionDelegate,
        addressValidator: AddressValidator,
        logger: Logger
    ) {
        self.sendTransactionDelegate = sendTransactionDelegate
        self.addressValidator = addressValidator
        self.logger = logger
    }

    func isNfcAvailable() -> Bool {
        return NFCNDEFReaderSession.readingAvailable
    }

    func initiateScan() {
        self.nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        self.nfcSession?.alertMessage = "Hold your iPhone near the Verge Tag."
        self.nfcSession?.begin()
    }

    // MARK: - NFC Functions

    internal func readerSession(_ nfcSession: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Processing Tag Data
        DispatchQueue.main.async {
            // Process detected NFCNDEFMessage object
            self.detectedNfcMessages.append(contentsOf: messages)
        }
    }

    internal func readerSession(_ nfcSession: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        // Processing NDEF Tag
        if tags.count > 1 {
            // Restart polling in 500ms
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            nfcSession.alertMessage = "More than 1 tag was detected, please try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                nfcSession.restartPolling()
            })
            return
        }

        // Connect to the found tag and perform NDEF message reading
        let tag = tags.first!
        nfcSession.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                nfcSession.alertMessage = "Unable to read Tag."
                nfcSession.invalidate()
                return
            }

            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, _: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    nfcSession.alertMessage = "Tag format is invalid or corrupted"
                    // Tag is not NDEF compliant
                    nfcSession.invalidate()
                    return
                } else if nil != error {
                    nfcSession.alertMessage = "Tag format is invalid or corrupted"
                    // Unable to query NDEF status of tag
                    nfcSession.invalidate()
                    return
                }

                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    var statusMessage: String
                    if nil != error || nil == message {
                        statusMessage = "Unable to read Tag"
                    } else {
                        statusMessage = "Tag read successfully!"
                        DispatchQueue.main.async {
                            self.processNfcMessage(message: message)
                        }
                    }

                    nfcSession.alertMessage = statusMessage
                    nfcSession.invalidate()
                })
            })
        })
    }

    internal func readerSession(_ nfcSession: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        self.logger.error("Nfc tx factory error: \(error.localizedDescription)")
    }

    private func processNfcMessage(message: NFCNDEFMessage?) {
        guard let message = message else {
            return
        }
        
        guard
            message.records.count > 0,
            message.records[0].typeNameFormat != .empty
        else {
            return
        }

        guard let payload = message.records.first, payload.typeNameFormat == .nfcWellKnown else {
            return
        }

        guard let url = payload.wellKnownTypeURIPayload()?.absoluteString else {
            return
        }
        
        self.addressValidator.validate(string: url) { isValid, address, amount, label, currency in
            let txFactory = self.sendTransactionDelegate.getSendTransaction()

            if let address = address, isValid {
                txFactory.address = address
            }

            if let amount = amount {
                if (currency == "XVG" || currency == nil) {
                    txFactory.amount = amount
                } else {
                    txFactory.fiatAmount = amount
                }
            }

            if let label = label {
                txFactory.memo = label
            }

            if let currency = currency {
                txFactory.update(currency: currency)
            }

            self.sendTransactionDelegate.didChangeSendTransaction(txFactory)
        }
    }
}
