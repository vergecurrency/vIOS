//
//  TxTransponderTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 12/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import XCTest
import Foundation
@testable import VergeiOS

class TxTransponderTest: XCTestCase {

    func testCreateATransactionProposal() {
        let walletClient = TxTransponderTest1WalletClient()
        let transponder = TxTransponder(walletClient: walletClient)
        
        let proposal = TxProposal(address: "DMTtEgS4JecxRhdTABPsgDJizPMAuTZFeU", amount: 10.0, message: "What a beauty")
        
        transponder.create(proposal: proposal) { txp, txerror, error in
            XCTAssertNotNil(txp)
            
            guard let txp = txp else {
                return
            }
            
            XCTAssertEqual(txp.network, "livenet")
            XCTAssertEqual(txp.coin, "xvg")
            XCTAssertEqual(txp.fee, 100000)
            XCTAssertEqual(txp.amount, 10000000)
            XCTAssertEqual(txp.outputs.first!.stealth, false)
            XCTAssertEqual(txp.outputs.first!.amount, 10000000)
            XCTAssertEqual(txp.outputs.first!.toAddress, "DMTtEgS4JecxRhdTABPsgDJizPMAuTZFeU")
            XCTAssertEqual(txp.inputs.first!.satoshis, 10100000)
            XCTAssertEqual(txp.inputs.first!.address, "DAjo2HJRR2kSi3yvxQyhLTrFWobfnJnbxc")
            XCTAssertEqual(txp.inputs.first!.path, "m/0/8")
            XCTAssertEqual(txp.inputs.first!.confirmations, 78174)
        }
    }

    func testCreatingATransactionProposalWithAInvalidAddress() {
        let walletClient = TxTransponderTest2WalletClient()
        let transponder = TxTransponder(walletClient: walletClient)

        let proposal = TxProposal(address: "sdokdsoijdsoijsd", amount: 10.0, message: "What a beauty")

        transponder.create(proposal: proposal) { txp, txerror, error in
            XCTAssertNil(txp)
            XCTAssertNotNil(txerror)

            XCTAssertEqual(txerror!.message, "Invalid address")
            XCTAssertEqual(txerror!.code, "INVALID_ADDRESS")
        }
    }

    func testSendingATransactionProposal() {
        let walletClient = TxTransponderTest3WalletClient()
        let transponder = TxTransponder(walletClient: walletClient)
        
        let proposal = TxProposal(address: "DMTtEgS4JecxRhdTABPsgDJizPMAuTZFeU", amount: 10.0, message: "What a beauty")
        
        transponder.create(proposal: proposal) { txp, txerror, error in
            XCTAssertNotNil(txp)
            
            guard let txp = txp else {
                return
            }
            
            XCTAssertEqual(txp.network, "livenet")
            XCTAssertEqual(txp.coin, "xvg")
            XCTAssertEqual(txp.fee, 100000)
            XCTAssertEqual(txp.amount, 10000000)
            XCTAssertEqual(txp.outputs.first!.stealth, false)
            XCTAssertEqual(txp.outputs.first!.amount, 10000000)
            XCTAssertEqual(txp.outputs.first!.toAddress, "DMTtEgS4JecxRhdTABPsgDJizPMAuTZFeU")
            XCTAssertEqual(txp.inputs.first!.satoshis, 10100000)
            XCTAssertEqual(txp.inputs.first!.address, "DAjo2HJRR2kSi3yvxQyhLTrFWobfnJnbxc")
            XCTAssertEqual(txp.inputs.first!.path, "m/0/8")
            XCTAssertEqual(txp.inputs.first!.confirmations, 78174)

            transponder.send(txp: txp) { response, response2, error in

            }
        }
    }
}

class TxTransponderTest1WalletClient: WalletClientMock {
    override func createTxProposal(
        proposal: TxProposal,
        completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void
    ) {
        let responseJson = "{\"walletM\":1,\"outputs\":[{\"message\":null,\"toAddress\":\"DMTtEgS4JecxRhdTABPsgDJizPMAuTZFeU\"," +
            "\"stealth\":false,\"amount\":10000000}],\"fee\":100000,\"coin\":\"xvg\",\"actions\":[],\"walletId\":\"fbd0c3d0-465c-4f4e-a890-d0e4bdb606e0\"," +
            "\"id\":\"b0aa5392-2e16-4dd6-a83a-80bff0dae927\",\"payProUrl\":null,\"feeLevel\":\"normal\",\"version\":3,\"message\":null,\"walletN\":1," +
            "\"requiredSignatures\":1,\"excludeUnconfirmedUtxos\":false,\"network\":\"livenet\",\"timestamp\":1555086257,\"amount\":10000000," +
            "\"inputs\":[{\"publicKeys\":[\"033036ed064cf98b70f0f9f62db8479f344c50d2b8832808c1bf9761f1fc2f4aa7\"],\"txid\":\"b2a146585bc6bbe97db73c0cd0e38308ac38eb1cb75c89746af1dade9c6400b9\"," +
            "\"path\":\"m\\/0\\/8\",\"amount\":0.10100000000000001,\"vout\":0,\"locked\":false,\"address\":\"DAjo2HJRR2kSi3yvxQyhLTrFWobfnJnbxc\",\"satoshis\":10100000," +
            "\"scriptPubKey\":\"76a9143d6890b4fffd829c31e64bf950fbefd2a8f1180d88ac\",\"confirmations\":78174}],\"createdOn\":1555086257,\"outputOrder\":[1,0]," +
            "\"requiredRejections\":1,\"feePerKb\":100000,\"addressType\":\"P2PKH\",\"creatorId\":\"566ea30247a20870c08b4db599fa1039ea00b55779942b788196709a702602cd\"," +
            "\"changeAddress\":{\"beRegistered\":null,\"publicKeys\":[\"0301714f0f46c402de5240063165c1dbcb018af72fb0381c8ae8eca765942e62f1\"],\"isChange\":true," +
            "\"type\":\"P2PKH\",\"createdOn\":1555086257,\"path\":\"m\\/1\\/81\",\"version\":\"1.0.0\",\"network\":\"livenet\",\"_id\":\"5cb0bbb1616c2628658f7d43\"," +
            "\"coin\":\"xvg\",\"address\":\"D7RMYX9r7vfe7piGwFbe1artpmxcLRHz1y\",\"walletId\":\"fbd0c3d0-465c-4f4e-a890-d0e4bdb606e0\"},\"inputPaths\":[\"m\\/0\\/8\"],\"status\":\"temporary\"}"

        let jsonData: Data = responseJson.data(using: .utf8)!
        let response = try? JSONDecoder().decode(TxProposalResponse.self, from: jsonData)

        completion(response, nil, nil)
    }
}

class TxTransponderTest2WalletClient: WalletClientMock {
    override func createTxProposal(
        proposal: TxProposal,
        completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void
    ) {
        let responseJson = "{\"message\":\"Invalid address\",\"code\":\"INVALID_ADDRESS\"}"
        let jsonData: Data = responseJson.data(using: .utf8)!
        let response = try? JSONDecoder().decode(TxProposalErrorResponse.self, from: jsonData)

        completion(nil, response, nil)
    }
}

class TxTransponderTest3WalletClient: TxTransponderTest1WalletClient {
    //
}

class WalletClientMock: WalletClientProtocol {
    func createWallet(walletName: String, copayerName: String, m: Int, n: Int, options: WalletOptions?, completion: @escaping (Error?, String?) -> Void) {}
    func joinWallet(walletIdentifier: String, completion: @escaping (Error?) -> Void) {}
    func openWallet(completion: @escaping (Error?) -> Void) {}
    func scanAddresses(completion: @escaping (Error?) -> Void) {}
    func createAddress(completion: @escaping (Error?, AddressInfo?, CreateAddressErrorResponse?) -> Void) {}
    func getBalance(completion: @escaping (Error?, WalletBalanceInfo?) -> Void) {}
    func getMainAddresses(options: WalletAddressesOptions?, completion: @escaping ([AddressInfo]) -> Void) {}
    func getTxHistory(skip: Int?, limit: Int?, completion: @escaping ([TxHistory]) -> Void) {}
    func getUnspentOutputs(address: String?, completion: @escaping ([UnspentOutput]) -> Void) {}
    func getSendMaxInfo(completion: @escaping (SendMaxInfo?) -> Void) {}
    func createTxProposal(proposal: TxProposal, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {}
    func publishTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {}
    func signTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {}
    func broadcastTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {}
    func rejectTxProposal(txp: TxProposalResponse, completion: @escaping (Error?) -> Void) {}
    func deleteTxProposal(txp: TxProposalResponse, completion: @escaping (Error?) -> Void) {}
    func getTxProposals(completion: @escaping ([TxProposalResponse], Error?) -> Void) {}
    func resetServiceUrl(baseUrl: String) {}
    func watchRequestCredentialsForMethodPath(path: String) -> WatchRequestCredentials {
        return WatchRequestCredentials(url: "url", copayerId: "copayerid", signature: "signature")
    }
}
