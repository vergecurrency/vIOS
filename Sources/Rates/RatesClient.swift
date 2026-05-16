//
//  RatesClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import Promises

class RatesClient {

    let httpSession: HttpSessionProtocol!

    init(httpSession: HttpSessionProtocol) {
        self.httpSession = httpSession
    }

    private func coinGeckoPriceUrl(currency: String) -> URL? {
        var components = URLComponents(string: Constants.priceDataEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "ids", value: "verge"),
            URLQueryItem(name: "vs_currencies", value: currency.lowercased()),
            URLQueryItem(name: "include_market_cap", value: "true"),
            URLQueryItem(name: "include_24hr_vol", value: "true"),
            URLQueryItem(name: "include_24hr_change", value: "true")
        ]

        return components?.url
    }

    func infoBy(currency: String, completion: @escaping (_ data: FiatRate?) -> Void) {
        guard let url = coinGeckoPriceUrl(currency: currency) else {
            return completion(nil)
        }

        self.httpSession.dataTask(with: url).then { response in
            let coinGeckoResponse = try response.dataToJson(type: CoinGeckoSimplePriceResponse.self)
            completion(try coinGeckoResponse.fiatRate(currency: currency))
        }.catch { error in
            completion(nil)
        }
    }

    func infoBy(currency: String) -> Promise<FiatRate> {
        guard let url = coinGeckoPriceUrl(currency: currency) else {
            return Promise<FiatRate> { _, reject in
                reject(NSError(domain: "RatesClient", code: -1))
            }
        }

        return self.httpSession.dataTask(with: url).then { response in
            let coinGeckoResponse = try response.dataToJson(type: CoinGeckoSimplePriceResponse.self)
            let rate = try coinGeckoResponse.fiatRate(currency: currency)

            return Promise {
                return rate
            }
        }
    }

}
