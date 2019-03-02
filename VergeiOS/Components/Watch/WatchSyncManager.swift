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
    public static let shared = WatchSyncManager()
    
    // MARK: Init
    
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(syncCurrency),
            name: .didChangeCurrency,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(syncAmount),
            name: .didChangeWalletAmount,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(syncAddress(notification:)),
            name: .didChangeReceiveAddress,
            object: nil
        )
    }
    
    // MARK: Private properties
    
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    private var validSession: WCSession? {
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
    }
    
    //MARK: Public methods
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    //MARK: Private methods
    
    @objc private func syncCurrency() {
        let currency = ApplicationRepository.default.currency;
        _ = self.transferMessage(message: ["currency" : currency as AnyObject])
    }
    
    @objc private func syncAmount() {
        let balanceCredentials = WalletClient.shared.watchRequestCredentialsForMethodPath(path: "/v1/balance/")
        if balanceCredentials.signature != nil &&
            balanceCredentials.url != nil &&
            balanceCredentials.copayerId != nil {
            
            self.transferMessage(message:
                ["balanceCredentials" : ["url" : balanceCredentials.url,
                                         "signature" : balanceCredentials.signature,
                                         "copayerId" : balanceCredentials.copayerId ] as AnyObject]
            )
        }
        
        let amount = ApplicationRepository.default.amount;
        let currency = ApplicationRepository.default.currency;
        
        self.transferMessage(message: ["amount" : amount,
                                           "currency" : currency as AnyObject])
    }
    
    @objc private func syncAddress(notification: Notification? = nil) {
        let address = notification?.object as! String;
        
        if var qrCodeObject = QRCode(address) {
            qrCodeObject.size = CGSize(width: 135, height: 135)
            qrCodeObject.color = CIColor(cgColor: UIColor(red: 0.11, green: 0.62, blue: 0.83, alpha: 1.0).cgColor)
            qrCodeObject.backgroundColor = CIColor(color: UIColor.white)
            
            let qrImg = qrCodeObject.image!
            let data = qrImg.pngData()
            
            self.transferMessage(message:
                ["address" : ["value" : address, "qr" : data! ] as AnyObject]
            )
        }
    }
    
    private func transferMessage(message: [String : AnyObject]) {
        validSession?.sendMessage(message,
                                  replyHandler: nil,
                                  errorHandler: nil)
    }
    
    //MARK: WCSessionDelegate
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
}

