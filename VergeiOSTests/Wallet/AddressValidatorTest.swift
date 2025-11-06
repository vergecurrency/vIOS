////
////  AddressValidatorTest.swift
////  VergeiOSTests
////
//
//import XCTest
//@testable import VergeiOS
//
//// MARK: - Mock Metadata
//class MockMetadata: MetadataStringValueProviding {
//    var stringValue: String?
//
//    init(_ string: String?) {
//        self.stringValue = string
//    }
//}
//
//// MARK: - Address Validator Tests
//class AddressValidatorTest: XCTestCase {
//
//    func testValidatingInvalidXVGAddress() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("sada")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertFalse(valid)
//            XCTAssertNil(address)
//            XCTAssertNil(amount)
//            XCTAssertNil(label)
//            XCTAssertNil(currency)
//        }
//    }
//
//    func testValidatingAnotherInvalidXVGAddress() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJusds")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertFalse(valid)
//            XCTAssertNil(address)
//            XCTAssertNil(amount)
//            XCTAssertNil(label)
//            XCTAssertNil(currency)
//        }
//    }
//
//    func testValidatingValidXVGAddress() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertTrue(valid)
//            XCTAssertEqual(address, "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
//            XCTAssertNil(amount)
//            XCTAssertNil(label)
//            XCTAssertNil(currency)
//        }
//    }
//
//    func testValidatingInvalidXVGAddressWithAmount() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("verge://DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJusddssd?amount=1000.0")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertFalse(valid)
//            XCTAssertNil(address)
//            XCTAssertNil(amount)
//            XCTAssertNil(label)
//            XCTAssertNil(currency)
//        }
//    }
//
//    func testValidatingValidXVGAddressWithAmount() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("verge://DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu?amount=1000.0")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertTrue(valid)
//            XCTAssertEqual(address, "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
//            XCTAssertEqual(amount, 1000.0)
//            XCTAssertNil(label)
//            XCTAssertNil(currency)
//        }
//    }
//
//    func testValidatingValidXVGAddressWithLargeAmount() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("verge:DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu?amount=454000.43")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertTrue(valid)
//            XCTAssertEqual(address, "DCys4K9buSLAgd4jG9qqZn3vB9CdXJLMJu")
//            XCTAssertEqual(amount, 454000.43)
//            XCTAssertNil(label)
//            XCTAssertNil(currency)
//        }
//    }
//
//    func testValidatingValidXVGAddressWithAmountLabelCurrency() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("verge://D6KvDwuxZgA3n1Qhg9SZj3gpGUYCUNo8AW?amount=0.10&currency=GBP&label=foobar")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertTrue(valid)
//            XCTAssertEqual(address, "D6KvDwuxZgA3n1Qhg9SZj3gpGUYCUNo8AW")
//            XCTAssertEqual(amount, 0.10)
//            XCTAssertEqual(label, "foobar")
//            XCTAssertEqual(currency, "GBP")
//        }
//    }
//
//    func testValidatingURLWithAddressAndAmount() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("https://tag.vergecurrency.business/?address=DJvRAkFBpexFPTBNic1ha8z3X4sqxsT46K&amount=332&currency=xvg")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertTrue(valid)
//            XCTAssertEqual(address, "DJvRAkFBpexFPTBNic1ha8z3X4sqxsT46K")
//            XCTAssertEqual(amount, 332)
//            XCTAssertNil(label)
//            XCTAssertNil(currency)
//        }
//    }
//
//    func testValidatingURLWithAddressOnly() {
//        let validator = AddressValidator()
//        let metadata = MockMetadata("Https://tag.vergecurrency.business/?address=DJvRAkFBpexFPTBNic1ha8z3X4sqxsT46K")
//
//        validator.validate(metadataObject: metadata) { valid, address, amount, label, currency in
//            XCTAssertTrue(valid)
//            XCTAssertEqual(address, "DJvRAkFBpexFPTBNic1ha8z3X4sqxsT46K")
//            XCTAssertNil(amount)
//            XCTAssertNil(label)
//            XCTAssertNil(currency)
//        }
//    }
//}
