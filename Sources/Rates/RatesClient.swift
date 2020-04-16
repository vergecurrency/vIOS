//
//  RatesClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

class RatesClient {

    let httpSession: HttpSessionProtocol!

    init(httpSession: HttpSessionProtocol) {
        self.httpSession = httpSession
    }

    func infoBy(currency: String, completion: @escaping (_ data: FiatRate?) -> Void) {
        let url = URL(string: "\(Constants.priceDataEndpoint)\(currency)")

        self.httpSession.dataTask(with: url!).then { response in
            completion(try response.dataToJson(type: FiatRate.self))
        }.catch { error in
            completion(nil)
        }
    }

}
