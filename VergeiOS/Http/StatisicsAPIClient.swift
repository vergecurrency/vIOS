//
//  StatisicsAPIClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import SwiftyJSON

class StatisicsAPIClient {

    let endpoint: String = "https://garagenet.internet-box.ch/api/v1/price/"
    
    func infoBy(currency: String, completion: @escaping (_ data: Statistics?) -> Void) {
        let url = URL(string: "\(endpoint)\(currency)")
    
        let task = TorClient.shared.session.dataTask(with: url!) { (data, resonse, error) in
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
}
