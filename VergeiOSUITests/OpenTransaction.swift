//
//  VergeiOSUITests.swift
//  VergeiOSUITests
//
//  Created by Swen van Zanten on 09-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import XCTest

class CreateNewWallet: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        app = XCUIApplication()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        // Fill in the app code
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        app.buttons["0"].tap()
        
        // Tap the "Send" tab
        app.buttons["Send"].tap()
        
        // Fill send address
        let textField = app.textFields["Enter the recipient address"]
        textField.tap()
        textField.typeText("my address")
    }
    
}
