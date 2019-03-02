//
//  StatsProvider.swift
//  VergeWatch Extension
//
//  Created by Ivan Manov on 3/1/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

public let didUpdateStats = NSNotification.Name(rawValue: "kWatchNotificationStatsUpdated")

class StatsProvider: NSObject {
    static let shared = StatsProvider()

    private var timer: Timer?
    
    var lastStats: FiatRate?
    
    // MARK: - Public methods
    
    func startUpdate() {
        self.updateStats()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            self.updateStats()
        }
    }
    
    func stopUpdate() {
        timer?.invalidate()
    }
    
    func updateStats() {
        self.getStatsForCurrency(currency: ConnectivityManager.shared.currency ?? "USD") { (stats) in
            if (stats != nil) {
                self.lastStats = stats
                NotificationCenter.default.post(name: didUpdateStats,
                                                object: stats)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func getStatsForCurrency(currency: String, completion: @escaping (_ result: FiatRate?) -> Void) {
        let url = URL(string: "\(Constants.priceDataEndpoint)\(currency)")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if let data = data {
                do {
                    let statistics = try JSONDecoder().decode(FiatRate.self, from: data)
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
}
