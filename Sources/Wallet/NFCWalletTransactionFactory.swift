//
//  NFCWalletTransactionFactory.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/09/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import CoreNFC
import Logging

class NFCWalletTransactionFactory: NSObject, NFCNDEFReaderSessionDelegate {
    private let sendTransactionDelegate: SendTransactionDelegate
    private let logger: Logger

    private var detectedNfcMessages = [NFCNDEFMessage]()
    private var nfcSession: NFCNDEFReaderSession?
    private var nfcAvailable = false
    private var nfcActive = false
    private var nfcIsVergeAddress = false
    private var nfcAddress = ""
    private var nfcLabel = ""
    private var nfcPaymentAmount = ""
    private var nfcPaymentCurrency = "XVG"
    private var nfcValidStandardAddress = false
    private var nfcValidStealthAddress = false

    init(sendTransactionDelegate: SendTransactionDelegate, logger: Logger) {
        self.sendTransactionDelegate = sendTransactionDelegate
        self.logger = logger
    }

    func isNfcAvailable() -> Bool {
        return NFCNDEFReaderSession.readingAvailable
    }

    @available(iOS 13.0, *)
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

    @available(iOS 13.0, *)
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

    @available(iOS 13.0, *)
    private func processNfcMessage(message: NFCNDEFMessage?) {
        let payload = message!.records[0]

        switch payload.typeNameFormat {

        case .nfcWellKnown:
            if String(data: payload.type, encoding: .utf8) != nil {
                if let url = payload.wellKnownTypeURIPayload() {

                    let rawNFCDataArr = url.absoluteString.split(separator: "?")

                    // Validate Verge Address Type
                    self.nfcIsVergeAddress = (rawNFCDataArr[0] == "https://tag.vergecurrency.business/")

                    if (nfcIsVergeAddress) {
                        self.processVergeDataTag(rawNFCDataArr: rawNFCDataArr[1])
                    }
                }
            }

        case .absoluteURI, .media, .nfcExternal, .empty, .unknown, .unchanged:
            fallthrough
        @unknown default:
            ()
        }

    }

    private func processVergeDataTag(rawNFCDataArr: String.SubSequence) {
        // Separate any Address Params into an array
        let vergeNFCDataComponents = rawNFCDataArr.split(separator: "&")

        // Grab the url params if they exist, and remove the urlparam itself
        for eachUrlParam in vergeNFCDataComponents {

            switch eachUrlParam {
            case let urlParam where urlParam.contains("address="):
                self.nfcAddress = String(eachUrlParam.replacingOccurrences(of: "address=", with: ""))

                // Validate Standard Address length
                // Reqd Length: 34
                self.nfcValidStandardAddress = (nfcAddress.count == 34)

                // Validate Stealth Address length
                // Reqd Length: 102
                self.nfcValidStealthAddress = (nfcAddress.count == 102)

            case let urlParam where urlParam.contains("label="):
                self.nfcLabel = String(eachUrlParam.replacingOccurrences(of: "label=", with: ""))
                self.nfcLabel = self.nfcLabel.removingPercentEncoding!

            case let urlParam where urlParam.contains("amount="):
                self.nfcPaymentAmount = String(eachUrlParam.replacingOccurrences(of: "amount=", with: ""))

            case let urlParam where urlParam.contains("currency="):
                self.nfcPaymentCurrency = String(eachUrlParam.replacingOccurrences(of: "currency=", with: ""))

                switch self.nfcPaymentCurrency {
                case "XVG",
                     "AUD", "BRL", "CAD", "CHF", "CNY",
                     "DKK", "EUR", "GBP", "HKD", "IDR",
                     "NZD", "RUB", "SGD", "THB", "USD":
                    () // OK - Supported Currencies
                default:
                    self.nfcPaymentCurrency = "XVG" // Unsupported - revert to XVG
                }

            default:
                () // Ignore
            }

        }

        if (self.nfcValidStandardAddress || self.nfcValidStealthAddress) {
            self.populateNfcDataToSendView()
        }
    }

    private func populateNfcDataToSendView() {
        if (self.nfcValidStandardAddress || self.nfcValidStealthAddress) {
            // At this point we have all the data required to
            // set the Address, Description, Amount and Currency of the transaction.
            let txFactory = self.sendTransactionDelegate.getSendTransaction()

            if (self.nfcValidStandardAddress || self.nfcValidStealthAddress) {
                txFactory.address = self.nfcAddress
            }

            if (self.nfcLabel.count > 0) {
                txFactory.memo = self.nfcLabel
            }

            if (self.nfcPaymentAmount.count > 0) {
                txFactory.setBy(
                    currency: self.nfcPaymentCurrency,
                    amount: Double(self.nfcPaymentAmount)! as NSNumber
                )
            }

            self.sendTransactionDelegate.didChangeSendTransaction(txFactory)
            self.resetNfcVariables() // Reset vars ready for next scan
        }
    }

    private func resetNfcVariables() {
        self.detectedNfcMessages = [NFCNDEFMessage]()
        self.nfcIsVergeAddress = false
        self.nfcAddress = ""
        self.nfcLabel = ""
        self.nfcPaymentAmount = ""
        self.nfcPaymentCurrency = "XVG"
        self.nfcValidStandardAddress = false
        self.nfcValidStealthAddress = false
    }
}
