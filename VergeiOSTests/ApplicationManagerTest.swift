//
//  WalletManagerTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 09-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import XCTest
@testable import VergeiOS

class ApplicationManagerTest: XCTestCase {
    
    func testSettingAndGettingAPin() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let manager = ApplicationRepository()
        
        manager.pin = ""
        
        XCTAssertTrue(manager.pin == "")
        
        manager.pin = "123456"
        
        XCTAssertTrue(manager.pin == "123456")
    }
    
}
