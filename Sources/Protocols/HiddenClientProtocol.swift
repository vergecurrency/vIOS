//
// Created by Swen van Zanten on 02/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation
import Promises

protocol HiddenClientProtocol {
    func getURLSession() -> Promise<URLSession>
}
