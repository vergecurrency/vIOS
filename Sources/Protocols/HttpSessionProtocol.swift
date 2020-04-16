//
// Created by Swen van Zanten on 16/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation
import Promises

protocol HttpSessionProtocol {
    func dataTask(with request: URLRequest) -> Promise<HttpResponse>
    func dataTask(with url: URL) -> Promise<HttpResponse>
}

enum HttpSessionError: Swift.Error {
    case nilDataReceived
}
