//
//  WatchSyncManager.swift
//  VergeiOS
//
//  Created by Ivan Manov on 1/27/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit
import WatchConnectivity

class WatchSyncManager: NSObject, WCSessionDelegate {
    static let shared = WatchSyncManager()
    
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
        let currency = ApplicationManager.default.currency;
        _ = self.transferMessage(message: ["currency" : currency as AnyObject])
    }
    
    @objc private func syncAmount() {
        let amount = ApplicationManager.default.amount;
        let currency = ApplicationManager.default.currency;
        
        _ = self.transferMessage(message: ["amount" : amount])
        _ = self.transferMessage(message: ["currency" : currency as AnyObject])
    }
    
    @objc private func syncAddress(notification: Notification? = nil) {
        let address = notification?.object as! String;
        _ = self.transferMessage(message: ["address" : address as AnyObject])
    }
    
    private func transferMessage(message: [String : AnyObject]){
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
