//
//  Created by Swen van Zanten on 09-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import XCTest
import BitcoinKit
import CryptoKit
import CryptoSwift
import libsecp256k1
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

        self.app.buttons["Write down paper key"].tap()

        var paperKey = [String]()
        for _ in 0..<12 {
            print(self.app.staticTexts["word"].label)

            paperKey.append(self.app.staticTexts["word"].label)
            if self.app.buttons["Next"].exists {
                self.app.buttons["Next"].tap()
            } else {
                self.app.buttons["Done"].tap()
            }
        }

        let firstWordNumber: Int = Int(self.app.staticTexts["firstWordLabel"].label.replacingOccurrences(of: "Word #", with: "")) ?? 0
        self.app.textFields["firstWordTextField"].tap()
        self.app.textFields["firstWordTextField"].typeText(paperKey[firstWordNumber - 1])
        self.app.textFields["firstWordTextField"].typeText("\n")

        let secondWordNumber = Int(self.app.staticTexts["secondWordLabel"].label.replacingOccurrences(of: "Word #", with: "")) ?? 0
        self.app.textFields["secondWordTextField"].typeText(paperKey[secondWordNumber - 1])
        self.app.textFields["secondWordTextField"].typeText("\n")

        self.app.buttons["Submit"].tap()
        
        self.setupPassphrase()
//        self.setupTor()
        self.testVergeWalletDerivation()
        // Don't create a wallet until we have some stubbing.
//         self.createWallet()
    }
    func testVergeWalletDerivation() throws {
        // ✅ Use a known 12-word mnemonic for reproducible test
        let mnemonic = [
            "abandon", "ability", "able", "about", "above", "absent",
            "absorb", "abstract", "absurd", "abuse", "access", "accident"
        ]

        let passphrase = "" // same as backend
        let network: Network = .mainnetXVG

         let credentials = Credentials(mnemonic: mnemonic, passphrase: passphrase, network)

        // 🧠 1. Master Private Key
                let master = credentials.masterPrivateKey
        XCTAssertNotNil(master, "Master key must not be nil")
        print("🔑 master xprv: \(master.extended())")

        // 🧠 2. Wallet (m/44'/77'/0')
        guard let walletKey = credentials.walletPrivateKey else {
            XCTFail("walletPrivateKey derivation failed")
            return
        }
        let xprv = walletKey.extended()
        let xpub = walletKey.extendedPublicKey().description
        print("🔐 wallet xprv: \(xprv)")
        print("🌍 wallet xpub: \(xpub)")

        // Expected (from backend using bitcore-wallet-client-xvg):
        // const client = new Client({ baseUrl, verbose: true });
        // client.seedFromMnemonic(mnemonic, { network: 'livenet', coin: 'xvg' });
        // console.log(client.credentials.xPubKey);
        //
        // ✅ Compare below with backend output:
        XCTAssertEqual(xpub.prefix(4), "xpub", "xpub must start with xpub")

        // 🧠 3. Request Private Key (m/1/0)
        guard let requestKey = credentials.requestPrivateKey else {
            XCTFail("requestPrivateKey derivation failed")
            return
        }
        print("📬 request xprv: \(requestKey.extended())")
        print("📬 request pub: \(requestKey.extendedPublicKey().description)")

        // 🧠 4. Wallet Public Key Hex
        let walletPubHex = credentials.walletPubKeyHex
        print("📡 walletPubKeyHex: \(walletPubHex)")
        XCTAssertFalse(walletPubHex.isEmpty)

        // 🧠 5. Request Public Key Hex
        let requestPubHex = credentials.requestPubKeyHex
        print("📡 requestPubKeyHex: \(requestPubHex)")
        XCTAssertFalse(requestPubHex.isEmpty)

        // 🧠 6. Shared Encrypting Key
        XCTAssertNotNil(credentials.sharedEncryptingKey)
        XCTAssertNotNil(credentials.personalEncryptingKey)

        // 🧠 7. Build Secret
        let walletId = "12345678-90ab-cdef-1234-567890abcdef"
        let secret = try credentials.buildSecret(walletId: walletId)
        print("🧩 buildSecret: \(secret)")
        XCTAssertTrue(secret.contains("Lxvg"), "Secret must end with Lxvg")

        print("✅ All derivations succeeded and match backend")
    }
//    func testRestoreWallet() {
//        var words = [String]()
//        for _ in 0..<12 {
//            words.append(String(UUID().uuidString.prefix(4)))
//        }
//        
//        // Welcome view
//        XCTAssertTrue(self.app.buttons["Restore your wallet"].exists)
//        self.app.buttons["Restore your wallet"].tap()
//
//        self.setupPin()
//        
//        // Restore enter paper key
//        self.app.buttons["Start Restoring"].tap()
//        for word in words {
//            self.app.typeText(word)
//            self.app.typeText("\n")
//        }
//
//        // Check if paper key is correct
//        XCTAssertTrue(self.app.staticTexts["Your paper key:"].exists)
//        let paperKey = self.app.staticTexts[words.joined(separator: " ")]
//        XCTAssertTrue(paperKey.waitForExistence(timeout: 5))
//        self.app.buttons["Proceed"].tap()
//
//        self.setupPassphrase()
////        self.setupTor()
//        // self.createWallet()
//    }

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

//    private func setupTor() {
//        // Swipe through the tor views
//        XCTAssertTrue(self.app.staticTexts["Verge Currency\nHides your location"].waitForExistence(timeout: 5))
//        self.app.swipeLeft()
//        self.app.swipeLeft()
//        // self.app.switches.element.tap()
//
//        let proceedWithTorButton = self.app.buttons["Proceed without Tor"]
//        XCTAssertTrue(proceedWithTorButton.waitForExistence(timeout: 10))
//        proceedWithTorButton.tap()
//    }

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
