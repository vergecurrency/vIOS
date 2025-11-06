//
//  BitcoreNodeClientTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 01/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import XCTest
@testable import VergeiOS

class BitcoreNodeClientTest: XCTestCase {

    var client: BitcoreNodeClient?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // self.client = BitcoreNodeClient(baseUrl: "/", torClient: self.torClient!)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
       
        self.client = nil
    }

    func testSend() throws {
        // self.client?.send(rawTx: "") { error, response in
        //     XCTAssert(error == nil)
        //     XCTAssert(response == nil)
        // }
    }

}
