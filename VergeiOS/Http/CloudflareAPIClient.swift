//
//  CloudflareAPIClient.swift
//  VergeiOS
//
//  Created by Ivan Manov on 19/08/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import SwiftyJSON

class CloudflareAPIClient {
    
    static let shared = CloudflareAPIClient()
    
    let endpoint: String = "https://dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion/dns-query?"
    
    func walletAddressFor(currency: String, domainName: String, completion: @escaping (_ address: String?) -> Void) {
        let url = URL(string: "\(endpoint)name=bans.\(currency).0.\(domainName)&type=TXT")
        
        var request = URLRequest(url: url!)
        request.setValue("application/dns-json", forHTTPHeaderField: "accept")
        
        let task = TorClient.shared.session.dataTask(with: request){ (data, resonse, error) in
            if let data = data {
                do {
                    let json = try JSON(data: data)
                    let result = json["Answer"][0]["data"].string?.replacingOccurrences(of: "\"", with: "")
                    
                    completion(result)
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

