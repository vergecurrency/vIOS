//
//  WalletManagerTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 09-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import XCTest
@testable import VergeiOS

class ApplicationRepositoryTest: XCTestCase {
    func testReceiveAddressPreferencesPersistAndStaySeparateForEachWallet() {
        let repository = ApplicationRepository()
        let originalProfile = repository.activeWalletProfileId
        let firstProfile = UUID().uuidString
        let secondProfile = UUID().uuidString
        defer {
            repository.activeWalletProfileId = originalProfile
            for profile in [firstProfile, secondProfile] {
                for key in ["wallet.staticReceiveAddress", "wallet.receiveAddress"] {
                    UserDefaults.standard.removeObject(forKey: "wallet.profiles.\(profile).\(key)")
                }
            }
        }

        repository.activeWalletProfileId = firstProfile
        XCTAssertTrue(repository.useStaticReceiveAddress)
        XCTAssertNil(repository.receiveAddress)
        repository.useStaticReceiveAddress = false
        repository.receiveAddress = "first-wallet-address"

        repository.activeWalletProfileId = secondProfile
        XCTAssertTrue(repository.useStaticReceiveAddress)
        XCTAssertNil(repository.receiveAddress)
        repository.receiveAddress = "second-wallet-address"

        let reloaded = ApplicationRepository()
        XCTAssertTrue(reloaded.useStaticReceiveAddress)
        XCTAssertEqual(reloaded.receiveAddress, "second-wallet-address")
        reloaded.activeWalletProfileId = firstProfile
        XCTAssertFalse(reloaded.useStaticReceiveAddress)
        XCTAssertEqual(reloaded.receiveAddress, "first-wallet-address")
    }
    
    func testSettingAndGettingAPin() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let manager = ApplicationRepository()
        let original = manager.pin
        
        manager.pin = ""
        
        XCTAssertTrue(manager.pin == "")
        
        manager.pin = "123456"
        
        XCTAssertTrue(manager.pin == "123456")
        
        manager.pin = original
    }
    
}
