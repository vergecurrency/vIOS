//
//  WatchWalletClient.swift
//  VergeWatch Extension
//
//  Created by Ivan Manov on 3/1/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

class WatchWalletClient: NSObject {
    private typealias URLCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
    
    public static let shared = WatchWalletClient()
    
    private var balanceUrl: String? {
        return ConnectivityManager.shared.balanceUrl;
    }
    private var copayerId: String? {
        return ConnectivityManager.shared.copayerId;
    }
    private var balanceSignature: String? {
        return ConnectivityManager.shared.balanceSignature;
    }
    
    // MARK: Public methods
    
    public func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: WalletBalanceInfo?) -> Void) {
        getBalanceRequest() { data, response, error in
            if let data = data {
                do {
//                    let dataString = String(data: data, encoding: String.Encoding.utf8)
                    let balanceInfo = try JSONDecoder().decode(WalletBalanceInfo.self, from: data)
                    completion(error, balanceInfo)
                } catch {
                    print(error)
                    completion(error, nil)
                }
            }
        }
    }
    
    // MARK: Private methods
    
    private func getBalanceRequest(completion: @escaping URLCompletion) {
        if self.balanceUrl == nil || self.copayerId == nil || self.balanceSignature == nil {
            return completion(nil, nil, NSError(domain: "Wrong data", code: 500))
        }
        
        print("Get request to: \(self.balanceUrl!)")
        print("And Copayer id: \(self.copayerId!)")
        print("With signature: \(self.balanceSignature!)")
        
        var request = URLRequest(url: URL(string: self.balanceUrl!)!)
        request.httpMethod = "GET"
        request.setValue(self.copayerId!, forHTTPHeaderField: "x-identity")
        request.setValue(self.balanceSignature!, forHTTPHeaderField: "x-signature")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.sync {
                completion(data, response, error)
            }
        }
        
        DispatchQueue.main.async {
            task.resume()
        }
    }
}
