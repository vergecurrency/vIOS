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
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertFalse(valid)
            XCTAssertTrue(address == nil)
            XCTAssertTrue(amount == nil)
            XCTAssertTrue(label == nil)
            XCTAssertTrue(currency == nil)
        }
    }
    
    func testValidatingAnotherInvalidXVGAddressByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJusds"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertFalse(valid)
            XCTAssertTrue(address == nil)
            XCTAssertTrue(amount == nil)
            XCTAssertTrue(label == nil)
            XCTAssertTrue(currency == nil)
        }
    }
    
    func testValidatingValidXVGAddressByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertTrue(valid)
            XCTAssertTrue(address == "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
            XCTAssertTrue(amount == nil)
            XCTAssertTrue(label == nil)
            XCTAssertTrue(currency == nil)
        }
    }
    
    func testValidatingInvalidXVGAddressAndAmountByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "verge://DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJusddssd?amount=1000.0"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertFalse(valid)
            XCTAssertTrue(address == nil)
            XCTAssertTrue(amount == nil)
            XCTAssertTrue(label == nil)
            XCTAssertTrue(currency == nil)
        }
    }
    
    func testValidatingValidXVGAddressAndAmountByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "verge://DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu?amount=1000.0"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertTrue(valid)
            XCTAssertTrue(address == "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
            XCTAssertTrue(amount == 1000.0)
        }
    }
    
    func testValidatingValidXVGAddressAndMoreAmountByAVMetadata() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "verge:DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu?amount=454000.43"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertTrue(valid)
            XCTAssertTrue(address == "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
            XCTAssertTrue(amount == 454000.43)
        }
    }
    
    func testValidatingValidXVGAddressAndMoreAmountByAVMetadata2() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "verge://D6KvDwuxZgA3n1Qhg9SZj3gpGUYCUNo8AW?amount=0.10&currency=GBP&label=foobar"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertTrue(valid)
            XCTAssertTrue(address == "D6KvDwuxZgA3n1Qhg9SZj3gpGUYCUNo8AW")
            XCTAssertTrue(amount == 0.10)
            XCTAssertTrue(label == "foobar")
            XCTAssertTrue(currency == "GBP")
        }
    }
    
    func testValidatingValidXVGAddressAndMoreAmountByAVMetadata3() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "https://tag.vergecurrency.business/?address=DJvRAkFBpexFPTBNic1ha8z3X4sqxsT46K&amount=332&currency=XVG"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertTrue(valid)
            XCTAssertTrue(address == "DJvRAkFBpexFPTBNic1ha8z3X4sqxsT46K")
            XCTAssertTrue(amount == 332)
            XCTAssertTrue(label == nil)
            XCTAssertTrue(currency == "XVG")
        }
    }
    
    func testValidatingValidXVGAddressAndMoreAmountByAVMetadata4() {
        let validator = AddressValidator()
        
        let metadata = AddressValidatorAVMetaData()
        metadata.returnStringValue = "Https://tag.vergecurrency.business/?address=DJvRAkFBpexFPTBNic1ha8z3X4sqxsT46K"
        
        validator.validate(metadataObject: metadata) { (valid, address, amount, label, currency) in
            XCTAssertTrue(valid)
            XCTAssertTrue(address == "DJvRAkFBpexFPTBNic1ha8z3X4sqxsT46K")
            XCTAssertTrue(amount == nil)
            XCTAssertTrue(label == nil)
            XCTAssertTrue(currency == nil)
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
