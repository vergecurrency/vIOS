//
//  IntentHandler.swift
//  VergeSiri
//
//  Created by Ivan Manov on 1/10/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Intents

@available(iOSApplicationExtension 12.0, *)
class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        guard intent is VergePriceIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return PriceIntentHandler()
    }
}

@available(iOSApplicationExtension 12.0, *)
class PriceIntentHandler: NSObject, VergePriceIntentHandling {
    
    func handle(intent: VergePriceIntent, completion: @escaping (VergePriceIntentResponse) -> Void) {
        
        getPriceForCurrency(currency: "USD") { (priceResult) in
            if (priceResult != nil && priceResult!.doubleValue >= 0) {
                let result = String(format: "%.4f $", priceResult!.doubleValue)
                completion(VergePriceIntentResponse.success(price: result))
            } else {
                completion(VergePriceIntentResponse.init(code: .failure, userActivity: nil))
            }
        }
    }
    
    func getPriceForCurrency(currency: String, completion: @escaping (_ result: NSDecimalNumber?) -> Void) {
        let url = URL(string: "\(Config.priceDataEndpoint)\(currency)")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if let data = data {
                do {
                    let statistics = try JSONDecoder().decode(Statistics.self, from: data)
                    completion(NSDecimalNumber(value: statistics.price))
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
