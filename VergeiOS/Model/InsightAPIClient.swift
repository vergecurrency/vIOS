//
//  InsightController.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 24.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

// Look https://github.com/bitpay/insight-api for local installation
// just for development
public class InsightAPIClient {
    private let baseEndpoint = "http://localhost:3001/insight-api/status?q=getinfo"
    private let session = URLSession(configuration: .default)
    
    //private let publicKey: String
    //private let privateKey: String
    
    /*public init(publicKey: String, privateKey: String) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }*/
    

    public func getInfo(retreiveFunc: @escaping (_ data: BlockchainInfo?) -> Void){
        let endpoint = URL(string: self.baseEndpoint)
        
        let task = session.dataTask(with: URLRequest(url: endpoint!)) { data, response, error in
            if let data = data {
                do {
                    // Decode the top level response, and look up the decoded response to see
                    // if it's a success or a failure
                    let marvelResponse = try JSONDecoder().decode(BlockchainInfo.self, from: data)
                    retreiveFunc(marvelResponse)

                } catch {
                    print("Error info: \(error)")
                    retreiveFunc(nil)
                }
            } else if let _ = error {
                retreiveFunc(nil)
            }
        }
        task.resume()
    }
    
}
