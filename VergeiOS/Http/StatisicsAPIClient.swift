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
    
    static let shared = StatisicsAPIClient()
    
    let endpoint: String = "https://min-api.cryptocompare.com/data/"
    
    func infoBy(currency: String, completion: @escaping (_ data: Statistics?) -> Void) {
        let url = URL(string: "\(endpoint)pricemultifull?fsyms=XVG&tsyms=\(currency)")
    
        let task = TorClient.shared.session.dataTask(with: url!) { (data, resonse, error) in
            if let data = data {
                do {
                    let json = try JSON(data: data)
                    let raw = try JSONDecoder().decode(
                        InfoRaw.self, from: try json["RAW"]["XVG"][currency].rawData()
                    )
                    let display = try JSONDecoder().decode(
                        InfoDisplay.self, from: try json["DISPLAY"]["XVG"][currency].rawData()
                    )
                    
                    completion(Statistics(raw: raw, display: display))
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
