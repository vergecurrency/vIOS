//
//  AddressValidatorTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 22-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import XCTest
import AVFoundation
@testable import VergeiOS

class AddressValidatorTest: XCTestCase {

    func testValidatingInvalidXVGAddressByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "sada"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount) in
            XCTAssert(!valid)
            XCTAssert(address == nil)
            XCTAssert(amount == nil)
        }
    }
    
    func testValidatingAnotherInvalidXVGAddressByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJusds"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount) in
            XCTAssert(!valid)
            XCTAssert(address == nil)
            XCTAssert(amount == nil)
        }
    }
    
    func testValidatingValidXVGAddressByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount) in
            XCTAssert(valid)
            XCTAssert(address == "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
            XCTAssert(amount == nil)
        }
    }
    
    func testValidatingInvalidXVGAddressAndAmountByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "verge://DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJusddssd?amount=1000.0"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount) in
            XCTAssert(!valid)
            XCTAssert(address == nil)
            XCTAssert(amount == nil)
        }
    }
    
    func testValidatingValidXVGAddressAndAmountByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "verge://DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu?amount=1000.0"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount) in
            XCTAssert(valid)
            XCTAssert(address == "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
            XCTAssert(amount == 1000.0)
        }
    }
    
    func testValidatingValidXVGAddressAndMoreAmountByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "verge:DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu?amount=454000.43"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount) in
            XCTAssert(valid)
            XCTAssert(address == "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
            XCTAssert(amount == 454000.43)
        }
    }
}

class AddressValidatorAVMetaData: AVMetadataMachineReadableCodeObject {
    init(hello: String = "") {}
    
    var returnStringValue = ""
    
    override var stringValue: String? {
        return returnStringValue
    }
}
