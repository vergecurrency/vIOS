//
// Created by Swen van Zanten on 03/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation
import Promises

struct HiddenHttpSessionRequest {
    let promise: Promise<HttpResponse>
    let completion: (Promise<HttpResponse>, URLSession) -> Void

    func fulfill(_ session: URLSession) {
        self.completion(self.promise, session)
    }

    func reject(_ error: Error) {
        self.promise.reject(error)
    }
}
