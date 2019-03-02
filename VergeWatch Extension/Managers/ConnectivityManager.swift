//
//  ConnectivityManager.swift
//  VergeWatch Extension
//
//  Created by Ivan Manov on 1/27/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import WatchConnectivity

public let didUpdateAddress = NSNotification.Name(rawValue: "kWatchNotificationAddressUpdated")

public let kWatchCurrency = NSNotification.Name(rawValue: "kWatchDefaultsCurrency").rawValue
public let kWatchAddress = NSNotification.Name(rawValue: "kWatchDefaultsAddress").rawValue
public let kWatchQrCode = NSNotification.Name(rawValue: "kWatchDefaultsQrCode").rawValue
public let kWatchAmount = NSNotification.Name(rawValue: "kWatchDefaultsAmount").rawValue

public let kWatchBalanceUrl = NSNotification.Name(rawValue: "kWatchDefaultsBalanceUrl").rawValue
public let kWatchCopayerId = NSNotification.Name(rawValue: "kWatchDefaultsCopayerId").rawValue
public let kWatchBanalceSignature = NSNotification.Name(rawValue: "kWatchDefaultsBalanceSignature").rawValue

class ConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = ConnectivityManager()
    
    private var wcSession: WCSession?
    
    // MARK: - Public properties
    
    private(set) var currency: String?
    private(set) var amount: NSNumber?
    private(set) var address: String?
    private(set) var qrCode: Data?
    
    private(set) var balanceUrl: String?
    private(set) var copayerId: String?
    private(set) var balanceSignature: String?
    
    override init() {
        currency = UserDefaults.standard.object(forKey: kWatchCurrency) as? String
        amount = UserDefaults.standard.object(forKey: kWatchAmount) as? NSNumber
        address = UserDefaults.standard.object(forKey: kWatchAddress) as? String
        qrCode = UserDefaults.standard.object(forKey: kWatchQrCode) as? Data
        
        //TODO create single balance credentials property instead
        balanceUrl = UserDefaults.standard.object(forKey: kWatchBalanceUrl) as? String
        copayerId = UserDefaults.standard.object(forKey: kWatchCopayerId) as? String
        balanceSignature = UserDefaults.standard.object(forKey: kWatchBanalceSignature) as? String
    }
    
    // MARK: - Public methods
    
    func startUpdate() {
        if (WCSession.isSupported()) {
            wcSession = WCSession.default;
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    func stopUpdate() {
        wcSession = nil
    }
    
    // MARK: - WCSessionDelegate
    
    internal func session(_ session: WCSession,
                          activationDidCompleteWith activationState: WCSessionActivationState,
                          error: Error?) {}
    
    public func session(_ session: WCSession,
                        didReceiveMessage message: [String : Any]) {
        
        if message["balanceCredentials"] != nil {
            let credentials = message["balanceCredentials"] as? Dictionary<String, Any>
            
            if credentials!["url"] != nil {
                self.balanceUrl = credentials!["url"] as? String
                UserDefaults.standard.set(self.balanceUrl, forKey: kWatchBalanceUrl)
            }
            
            if credentials!["copayerId"] != nil {
                self.copayerId = credentials!["copayerId"] as? String
                UserDefaults.standard.set(self.copayerId, forKey: kWatchCopayerId)
            }
            
            if credentials!["signature"] != nil {
                self.balanceSignature = credentials!["signature"] as? String
                UserDefaults.standard.set(self.balanceSignature, forKey: kWatchBanalceSignature)
            }
        }
        
        if message["amount"] != nil {
            self.amount = message["amount"] as? NSNumber
            UserDefaults.standard.set(self.amount, forKey: kWatchAmount)
        }
        
        if message["currency"] != nil {
            let currency = message["currency"] as? String
            if  currency != self.currency {
                self.currency = currency;
                UserDefaults.standard.set(self.currency, forKey: kWatchCurrency)
                StatsProvider.shared.updateStats() // Update stats on currency change
            }
        }
        
        if message["address"] != nil {
            let addressInfo = message["address"] as? Dictionary<String, Any>
            
            self.address = (addressInfo!["value"] as! String)
            self.qrCode = (addressInfo!["qr"] as! Data)
            
            UserDefaults.standard.set(self.address, forKey: kWatchAddress)
            UserDefaults.standard.set(self.qrCode, forKey: kWatchQrCode)
            
            NotificationCenter.default.post(name: didUpdateAddress,
                                            object: nil)
        }
    }
}
