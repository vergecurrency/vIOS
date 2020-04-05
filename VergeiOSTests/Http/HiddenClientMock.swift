//
// Created by Swen van Zanten on 03/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation
import Promises
@testable import VergeiOS

class HiddenClientMock: HiddenClientProtocol {
    var session: URLSession? = URLSession.shared
    var data: Data? = nil
    var urlResponse: URLResponse? = nil

    func getURLSession() -> Promise<URLSession> {
        Promise<URLSession> { fulfill, reject in
            guard let session = self.session else {
                return reject(NSError(domain: "Waited too long for tor connection", code: 500))
            }

            fulfill(session)
        }
    }
}
