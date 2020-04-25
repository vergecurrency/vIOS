//
//  Created by Swen van Zanten on 09-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import XCTest

class SetupiOSWalletTests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        self.continueAfterFailure = false

        self.app = XCUIApplication()
        self.app.launchArguments.append("--uitesting")
        self.app.launchArguments.append("--uitesting-reset")
        self.app.launch()
    }

    func testSetupWallet() {
        // Welcome view
        XCTAssertTrue(self.app.buttons["Create a new wallet"].exists)
        self.app.buttons["Create a new wallet"].tap()

        self.setupPin()

        // TODO: record paper key and perform validation

        //self.setupPassphrase()
        //self.setupTor()
        //self.createWallet()
    }

    func testRestoreWallet() {
        // Welcome view
        XCTAssertTrue(self.app.buttons["Restore your wallet"].exists)
        self.app.buttons["Restore your wallet"].tap()

        self.setupPin()

        // Restore enter paper key
        self.app.buttons["Start Restoring"].tap()
        for _ in 0..<12 {
            self.app.typeText("test")
            self.app.typeText("\n")
        }

        // Check if paper key is correct
        XCTAssertTrue(self.app.staticTexts["Your paper key:"].exists)
        let paperKey = self.app.staticTexts["test test test test test test test test test test test test"]
        XCTAssertTrue(paperKey.waitForExistence(timeout: 5))
        self.app.buttons["Proceed"].tap()

        self.setupPassphrase()
        self.setupTor()
        self.createWallet()
    }

    private func setupPin() {
        // Setup PIN
        XCTAssertTrue(self.app.staticTexts["Set wallet PIN"].exists)
        for _ in 0..<6 {
            self.app.buttons["0"].tap()
        }

        // Again
        let reenterLabel = self.app.staticTexts["Re-enter the PIN"]
        XCTAssertTrue(reenterLabel.waitForExistence(timeout: 5))
        for _ in 0..<6 {
            self.app.buttons["0"].tap()
        }
        self.app.buttons["Proceed"].tap()
    }

    private func setupPassphrase() {
        // Fill in a passphrase
        XCTAssertTrue(self.app.staticTexts["Derive your paper key with a passphrase"].waitForExistence(timeout: 5))
        let passPhrase = "HelloWorld1"
        self.app.secureTextFields.element.tap()
        self.app.secureTextFields.element.typeText(passPhrase)
        self.app.secureTextFields.element.typeText("\n")

        // Again
        self.app.secureTextFields.element.tap()
        self.app.secureTextFields.element.typeText(passPhrase)
        self.app.secureTextFields.element.typeText("\n")
    }

    private func setupTor() {
        // Swipe through the tor views
        XCTAssertTrue(self.app.staticTexts["Verge Currency\nHides your location"].waitForExistence(timeout: 5))
        self.app.swipeLeft()
        self.app.swipeLeft()
        self.app.switches.element.tap()

        let proceedWithTorButton = self.app.buttons["Proceed with Tor"]
        XCTAssertTrue(proceedWithTorButton.waitForExistence(timeout: 10))
        proceedWithTorButton.tap()
    }

    private func createWallet() {
        // Accept all terms
        for uiSwitch in self.app.switches.allElementsBoundByIndex {
            if !uiSwitch.exists {
                break
            }
            uiSwitch.tap()
        }

        self.app.buttons["Create Wallet"].tap()

        let walletCreatedButton = self.app.buttons["Open your wallet"]
        XCTAssertTrue(walletCreatedButton.waitForExistence(timeout: 15))
        walletCreatedButton.tap()

        XCTAssertTrue(self.app.staticTexts["No transactions received yet."].waitForExistence(timeout: 5))
    }
}
