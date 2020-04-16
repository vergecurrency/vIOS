//
// Created by Swen van Zanten on 03/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

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
