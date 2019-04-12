//
//  RatesClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

class RatesClient {

    let torClient: TorClient!

    init(torClient: TorClient) {
        self.torClient = torClient
    }

    func infoBy(currency: String, completion: @escaping (_ data: FiatRate?) -> Void) {
        let url = URL(string: "\(Constants.priceDataEndpoint)\(currency)")
    
        let task = self.torClient.session.dataTask(with: url!) { data, resonse, error in
            guard let data = data else {
                return completion(nil)
            }

            DispatchQueue.main.sync {
                completion(try? JSONDecoder().decode(FiatRate.self, from: data))
            }
        }
        
        task.resume()
    }

}
