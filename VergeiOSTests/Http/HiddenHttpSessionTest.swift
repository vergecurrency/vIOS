//
//  HiddenHttpSessionTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 03/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import XCTest
import Foundation
import Promises
import PromisesTestHelpers
@testable import VergeiOS

class HiddenHttpSessionTest: XCTestCase {

    var client: HiddenClientProtocol!
    var session: HiddenHttpSession!

    override func setUpWithError() throws {
        self.client = HiddenClientMock()
        self.session = HiddenHttpSession(hiddenClient: self.client)
    }

    func testUrlResponseDataNil() throws {
        guard let url = URL(string: "test") else {
            throw NSError()
        }

        self.session.dataTask(with: url).then { response in
            XCTAssertTrue(response.data == nil)
        }
    }

    func testRequestResponseDataNil () throws {
        guard let url = URL(string: "test") else {
            throw NSError()
        }

        let urlRequest = URLRequest(url: url)

        self.session.dataTask(with: urlRequest).then { response in
            XCTAssertTrue(response.data == nil)
        }
    }

}
