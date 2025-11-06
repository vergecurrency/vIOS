//
// Created by Swen van Zanten on 03/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation
import Promises

class HttpResponse {
    let data: Data
    let urlResponse: URLResponse?

    init(data: Data, urlResponse: URLResponse?) {
        self.data = data
        self.urlResponse = urlResponse
    }

    func dataToJson<T>(type: T.Type) throws -> T where T : Decodable {
        return try JSONDecoder().decode(type.self, from: data)
    }
}

final class HttpSession: HttpSessionProtocol {

    func dataTask(with request: URLRequest) -> Promise<HttpResponse> {
        return Promise<HttpResponse> { fulfill, reject in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    reject(error)
                    return
                }

                guard let data = data else {
                    reject(HttpSessionError.nilDataReceived)
                    return
                }

                fulfill(HttpResponse(data: data, urlResponse: response))
            }
            task.resume()
        }
    }

    func dataTask(with url: URL) -> Promise<HttpResponse> {
        return dataTask(with: URLRequest(url: url))
    }
}
