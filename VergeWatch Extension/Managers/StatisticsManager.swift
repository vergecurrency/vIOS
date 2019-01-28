//
//  StatisticsManager.swift
//  VergeWatch Extension
//
//  Created by Ivan Manov on 1/27/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import WatchConnectivity

public let didUpdateStats = NSNotification.Name(rawValue: "kWatchNotificationStatsUpdated")
public let didUpdateAddress = NSNotification.Name(rawValue: "kWatchNotificationAddressUpdated")

public let kWatchCurrency = NSNotification.Name(rawValue: "kWatchDefaultsCurrency").rawValue
public let kWatchAddress = NSNotification.Name(rawValue: "kWatchDefaultsAddress").rawValue
public let kWatchQrCode = NSNotification.Name(rawValue: "kWatchDefaultsQrCode").rawValue
public let kWatchAmount = NSNotification.Name(rawValue: "kWatchDefaultsAmount").rawValue

class StatisticsManager: NSObject, WCSessionDelegate {
    static let shared = StatisticsManager()
    
    private var wcSession: WCSession?
    private var timer: Timer?
    
    // MARK: - Public properties
    
    var currency: String!
    var amount: NSNumber!
    var address: String!
    var qrCode: Data!
    
    override init() {
        currency = UserDefaults.standard.object(forKey: kWatchCurrency) as? String
        amount = UserDefaults.standard.object(forKey: kWatchAmount) as? NSNumber
        address = UserDefaults.standard.object(forKey: kWatchAddress) as? String
        qrCode = UserDefaults.standard.object(forKey: kWatchQrCode) as? Data
    }
    
    var lastStats: Statistics?
    
    // MARK: - Public methods
    
    func startUpdate() {
        self.updateStats()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            self.updateStats()
        }
        
        if (WCSession.isSupported()) {
            wcSession = WCSession.default;
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    func stopUpdate() {
        timer?.invalidate()
        wcSession = nil
    }
    
    // MARK: - Private methods
    
    private func updateStats() {
        self.getStatsForCurrency(currency: self.currency ?? "USD") { (stats) in
            if (stats != nil) {
                self.lastStats = stats
                NotificationCenter.default.post(name: didUpdateStats,
                                                object: stats)
            }
        }
    }
    
    private func getStatsForCurrency(currency: String, completion: @escaping (_ result: Statistics?) -> Void) {
        let url = URL(string: "\(Config.priceDataEndpoint)\(currency)")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if let data = data {
                do {
                    let statistics = try JSONDecoder().decode(Statistics.self, from: data)
                    completion(statistics)
                } catch {
                    print("Error info: \(error)")
                    completion(nil)
                }
            } else if let _ = error {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // MARK: - WCSessionDelegate
    
    internal func session(_ session: WCSession,
                          activationDidCompleteWith activationState: WCSessionActivationState,
                          error: Error?) {
        
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if (message["amount"] != nil) {
            self.amount = (message["amount"] as! NSNumber)
            UserDefaults.standard.set(self.amount, forKey: kWatchAmount)
        }
        
        if (message["currency"] != nil) {
            self.currency = (message["currency"] as! String)
            UserDefaults.standard.set(self.currency, forKey: kWatchCurrency)
        }
        
        if (message["address"] != nil) {
            let addressInfo = message["address"] as! Dictionary<String, Any>
            
            self.address = (addressInfo["value"] as! String)
            self.qrCode = (addressInfo["qr"] as! Data)
            
            UserDefaults.standard.set(self.address, forKey: kWatchAddress)
            UserDefaults.standard.set(self.qrCode, forKey: kWatchQrCode)
            
            NotificationCenter.default.post(name: didUpdateAddress,
                                            object: nil)
        }
        
        self.updateStats()
    }
}

