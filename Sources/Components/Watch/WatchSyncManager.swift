//
//  WatchSyncManager.swift
//  VergeiOS
//
//  Created by Ivan Manov on 1/27/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit
import WatchConnectivity
import QRCode

class WatchSyncManager: NSObject, WCSessionDelegate {

    private var walletClient: WalletClientProtocol!

    // MARK: Init

    private override init() {
        super.init()
    }

    init(walletClient: WalletClientProtocol) {
        super.init()

        self.walletClient = walletClient
    }

    // MARK: Private properties

    let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    private var validSession: WCSession? {
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }

        return nil
    }

    // MARK: Public methods

    func startSession() {
        session?.delegate = self
        session?.activate()
    }

    // MARK: Private methods

    @objc public func syncCurrency() {
        let currency = ApplicationRepository().currency
        _ = self.transferMessage(message: ["currency": currency as AnyObject])
    }

    @objc public func syncAmount() {
        guard let balanceCredentials = try? self.walletClient.watchRequestCredentialsForMethodPath(
            path: "/v1/balance/"
        ) else {
            return // TODO: handle error
        }

        if balanceCredentials.signature != nil &&
            balanceCredentials.url != nil &&
            balanceCredentials.copayerId != nil {

            self.transferMessage(message: [
                "balanceCredentials": [
                    "url": balanceCredentials.url,
                    "signature": balanceCredentials.signature,
                    "copayerId": balanceCredentials.copayerId
                ] as AnyObject
            ])
        }

        let amount = ApplicationRepository().amount
        let currency = ApplicationRepository().currency

        self.transferMessage(message: ["amount": amount, "currency": currency as AnyObject])
    }

    @objc public func syncAddress(notification: Notification? = nil) {
        let address = notification?.object as! String

        if var qrCodeObject = QRCode(address) {
            qrCodeObject.size = CGSize(width: 135, height: 135)
            qrCodeObject.color = CIColor(cgColor: UIColor(red: 0.11, green: 0.62, blue: 0.83, alpha: 1.0).cgColor)
            qrCodeObject.backgroundColor = CIColor(color: UIColor.white)

            let qrImg = qrCodeObject.image!
            let data = qrImg.pngData()

            self.transferMessage(message: ["address": ["value": address, "qr": data! ] as AnyObject])
        }
    }

    private func transferMessage(message: [String: AnyObject]) {
        validSession?.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }

    // MARK: WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
}
