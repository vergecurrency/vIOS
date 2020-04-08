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

        var didPublishTxEventFired = false
        var didSignTxEventFired = false
        var didBroadTxEventFired = false

        NotificationCenter.default.addObserver(forName: .didPublishTx, object: nil, queue: .main) { notification in
            didPublishTxEventFired = true
        }

        NotificationCenter.default.addObserver(forName: .didSignTx, object: nil, queue: .main) { notification in
            didSignTxEventFired = true
        }

        NotificationCenter.default.addObserver(forName: .didBroadcastTx, object: nil, queue: .main) { notification in
            didBroadTxEventFired = true
        }
        
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
                XCTAssertNil(response2)
                XCTAssertNil(error)
                XCTAssertTrue(didPublishTxEventFired)
                XCTAssertTrue(didSignTxEventFired)
                XCTAssertTrue(didBroadTxEventFired)
                XCTAssertNotNil(response)

                guard let response = response else {
                    return
                }

                XCTAssertEqual(response.network, "livenet")
                XCTAssertEqual(response.coin, "xvg")
                XCTAssertEqual(response.fee, 100000)
                XCTAssertEqual(response.amount, 10000000)
                XCTAssertEqual(response.outputs.first!.stealth, false)
                XCTAssertEqual(response.outputs.first!.amount, 10000000)
                XCTAssertEqual(response.outputs.first!.toAddress, "D5L9sbg1RMPS8yuVpw6jA3Cc1CpYH1shgk")
                XCTAssertEqual(response.inputs.first!.satoshis, 10100000)
                XCTAssertEqual(response.inputs.first!.address, "DQ8TVJGrVPQEYQiGMwnUvP15MdTFP8yBXJ")
                XCTAssertEqual(response.inputs.first!.path, "m/0/0")
                XCTAssertEqual(response.inputs.first!.confirmations, 28)
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
    override func publishTxProposal(
        txp: TxProposalResponse,
        completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void
    ) {
        let responseJson = "{\"walletM\":1,\"version\":3,\"fee\":100000,\"requiredRejections\":1,\"" +
            "creatorName\":\"{\\\"iv\\\":\\\"eB2o+MVCryZtGlx5DuXY9A==\\\",\\\"v\\\":1,\\\"iter\\\":1,\\\"ks\\\":128,\\\"ts\\\":64,\\\"mode\\\":\\\"ccm\\\",\\\"adata\\\":\\\"\\\",\\\"cipher\\\":\\\"aes\\\",\\\"ct\\\":\\\"1P2zc0PomM9GfWQDkZ4Aleyn4Q==\\\"}\"," +
            "\"walletN\":1,\"id\":\"b7b96d6d-e5ef-4026-9397-68cac55307fe\",\"changeAddress\":{\"path\":\"m\\/1\\/3\",\"version\":\"1.0.0\",\"coin\":\"xvg\"," +
            "\"publicKeys\":[\"0359bb7d586cc4c245d0232f9187029faf76b593c1e2dba82eba2c000ed416c168\"],\"_id\":\"5cb1bebd616c2628658f7d63\"," +
            "\"hasActivity\":null,\"type\":\"P2PKH\",\"network\":\"livenet\",\"beRegistered\":null,\"createdOn\":1555152573," +
            "\"address\":\"DHjThJe4M3Kpvr7b8BKifsTLQygFMpq7g3\",\"isChange\":true,\"walletId\":\"3547a0ad-2273-4403-ae38-dd0ecdf86d4f\"}," +
            "\"inputs\":[{\"amount\":0.10100000000000001,\"address\":\"DQ8TVJGrVPQEYQiGMwnUvP15MdTFP8yBXJ\",\"vout\":0,\"locked\":false," +
            "\"path\":\"m\\/0\\/0\",\"confirmations\":13,\"txid\":\"442c938c6c258f62ab349b5273b00e190af89c96faa3e8eee7941dfb38e85be0\"," +
            "\"satoshis\":10100000,\"publicKeys\":[\"031a661e0ee71dc72abcfe37d069bcf41b88448f6955ac75fdc4c6c9ea44480098\"]," +
            "\"scriptPubKey\":\"76a914d04b76146225d93e206f8c34b461403791b7264288ac\"}],\"network\":\"livenet\",\"createdOn\":1555152573," +
            "\"timestamp\":1555152573,\"customData\":null,\"feeLevel\":\"normal\",\"payProUrl\":null,\"requiredSignatures\":1," +
            "\"inputPaths\":[\"m\\/0\\/0\"],\"feePerKb\":100000,\"proposalSignature\":\"3045022100fe0728dedbdf2b6b59a737530a676da0df3d16b09461472ab60b31101fca87f102202ae5a8c588390dca7f5ba06c632044e49803526c76ac211457dc75bccc371ab9\"," +
            "\"actions\":[],\"amount\":10000000,\"status\":\"pending\",\"creatorId\":\"8830a04d48c0dcded327806fc903b0f9b5ada46d9a12e0796da40b80e5a2b72c\"," +
            "\"outputOrder\":[0,1],\"derivationStrategy\":\"BIP44\",\"addressType\":\"P2PKH\",\"coin\":\"xvg\",\"message\":null,\"excludeUnconfirmedUtxos\":false," +
            "\"outputs\":[{\"toAddress\":\"D5L9sbg1RMPS8yuVpw6jA3Cc1CpYH1shgk\",\"message\":null,\"stealth\":false,\"amount\":10000000}],\"walletId\":\"3547a0ad-2273-4403-ae38-dd0ecdf86d4f\"}"

        let jsonData: Data = responseJson.data(using: .utf8)!
        let response = try? JSONDecoder().decode(TxProposalResponse.self, from: jsonData)

        completion(response, nil, nil)
    }

    override func signTxProposal(
        txp: TxProposalResponse,
        completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void
    ) {
        let responseJson = "{\"payProUrl\":null,\"requiredRejections\":1,\"coin\":\"xvg\",\"excludeUnconfirmedUtxos\":false," +
            "\"creatorId\":\"8830a04d48c0dcded327806fc903b0f9b5ada46d9a12e0796da40b80e5a2b72c\",\"id\":\"e72711ed-4ada-4ee3-9d60-deb2ed052f39\"," +
            "\"inputs\":[{\"publicKeys\":[\"031a661e0ee71dc72abcfe37d069bcf41b88448f6955ac75fdc4c6c9ea44480098\"],\"satoshis\":10100000," +
            "\"txid\":\"442c938c6c258f62ab349b5273b00e190af89c96faa3e8eee7941dfb38e85be0\",\"confirmations\":28,\"scriptPubKey\":\"76a914d04b76146225d93e206f8c34b461403791b7264288ac\"," +
            "\"vout\":0,\"address\":\"DQ8TVJGrVPQEYQiGMwnUvP15MdTFP8yBXJ\",\"amount\":0.10100000000000001,\"path\":\"m\\/0\\/0\"," +
            "\"locked\":false}],\"addressType\":\"P2PKH\",\"timestamp\":1555153186,\"outputOrder\":[0,1],\"txid\":\"b92dcf62d353a25a456adaf6c2e2159747f78e7074d2afa3d5c7e659a8a4cee6\"," +
            "\"changeAddress\":{\"_id\":\"5cb1c122616c2628658f7d66\",\"walletId\":\"3547a0ad-2273-4403-ae38-dd0ecdf86d4f\",\"isChange\":true," +
            "\"beRegistered\":null,\"createdOn\":1555153186,\"coin\":\"xvg\",\"network\":\"livenet\",\"version\":\"1.0.0\",\"address\":\"DQsYoSg3h78zMFiifGH3UfneLw7i1CAkmy\"," +
            "\"type\":\"P2PKH\",\"hasActivity\":null,\"publicKeys\":[\"039d9f41b75ab3baaadd8f3e06b7a37797d84cf00bf358d89cb50efb172b101ad5\"]," +
            "\"path\":\"m\\/1\\/4\"},\"status\":\"accepted\",\"creatorName\":\"{\\\"iv\\\":\\\"eB2o+MVCryZtGlx5DuXY9A==\\\",\\\"v\\\":1,\\\"iter\\\":1,\\\"ks\\\":128,\\\"ts\\\":64,\\\"mode\\\":\\\"ccm\\\",\\\"adata\\\":\\\"\\\",\\\"cipher\\\":\\\"aes\\\",\\\"ct\\\":\\\"1P2zc0PomM9GfWQDkZ4Aleyn4Q==\\\"}\"," +
            "\"feePerKb\":100000,\"proposalSignaturePubKeySig\":null,\"walletId\":\"3547a0ad-2273-4403-ae38-dd0ecdf86d4f\",\"version\":3," +
            "\"actions\":[{\"type\":\"accept\",\"signatures\":[\"30450221008c222a0edf83275e5849d62cb09e57554d96ab643d9ab7af26021f3f9921f8ba02201247b030df5f8f734c679abf1a4e5cb26e3e2824b142a7792f0ed2dc5faf456d\"]," +
            "\"xpub\":\"ToEA6kpDTfS2mToqS7yg6xzX6kSj8spwrq611jkdGL4fFitpGg8s4uFC5WpQ5839tYMnSbkc59YB23w4sRw2jvpyygBbb9YAcSUqiRuCyicQVz4\"," +
            "\"copayerId\":\"8830a04d48c0dcded327806fc903b0f9b5ada46d9a12e0796da40b80e5a2b72c\",\"version\":\"1.0.0\",\"createdOn\":1555153191," +
            "\"comment\":null}],\"requiredSignatures\":1,\"outputs\":[{\"amount\":10000000,\"toAddress\":\"D5L9sbg1RMPS8yuVpw6jA3Cc1CpYH1shgk\"," +
            "\"message\":null,\"stealth\":false}],\"proposalSignaturePubKey\":null,\"network\":\"livenet\",\"createdOn\":1555153186," +
            "\"derivationStrategy\":\"BIP44\",\"broadcastedOn\":null,\"walletN\":1,\"inputPaths\":[\"m\\/0\\/0\"],\"fee\":100000," +
            "\"amount\":10000000,\"message\":null,\"proposalSignature\":\"304402200db38b10cf977e5aa4f142168a3846c90291741cb9b224f1758c73e674bfa59c02204cb4a07a435a71b5b38cb9b89f28a06063afd889737eb488b26ca88f18c5c40b\"," +
            "\"walletM\":1,\"feeLevel\":\"normal\",\"customData\":null,\"raw\":\"0100000022c1b15c01e05be838fb1d94e7eee8a3fa969cf80a190eb073529b34ab628f256c8c932c44000000006b4830450221008c222a0edf83275e5849d62cb09e57554d96ab643d9ab7af26021f3f9921f8ba02201247b030df5f8f734c679abf1a4e5cb26e3e2824b142a7792f0ed2dc5faf456d0121031a661e0ee71dc72abcfe37d069bcf41b88448f6955ac75fdc4c6c9ea44480098ffffffff0180969800000000001976a91402175bb34e8df3dd2644221a6df2c564c4ff90db88ac00000000\"}"

        let jsonData: Data = responseJson.data(using: .utf8)!
        let response = try? JSONDecoder().decode(TxProposalResponse.self, from: jsonData)

        completion(response, nil, nil)
    }

    override func broadcastTxProposal(
        txp: TxProposalResponse,
        completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void
    ) {
        let responseJson = "{\"outputOrder\":[0,1],\"excludeUnconfirmedUtxos\":false,\"creatorName\":\"{\\\"iv\\\":\\\"eB2o+MVCryZtGlx5DuXY9A==\\\",\\\"v\\\":1,\\\"iter\\\":1,\\\"ks\\\":128,\\\"ts\\\":64,\\\"mode\\\":\\\"ccm\\\",\\\"adata\\\":\\\"\\\",\\\"cipher\\\":\\\"aes\\\",\\\"ct\\\":\\\"1P2zc0PomM9GfWQDkZ4Aleyn4Q==\\\"}\"," +
            "\"derivationStrategy\":\"BIP44\",\"requiredSignatures\":1,\"outputs\":[{\"amount\":10000000,\"toAddress\":\"D5L9sbg1RMPS8yuVpw6jA3Cc1CpYH1shgk\"," +
            "\"message\":null,\"stealth\":false}],\"status\":\"broadcasted\",\"inputs\":[{\"publicKeys\":[\"031a661e0ee71dc72abcfe37d069bcf41b88448f6955ac75fdc4c6c9ea44480098\"]," +
            "\"satoshis\":10100000,\"txid\":\"442c938c6c258f62ab349b5273b00e190af89c96faa3e8eee7941dfb38e85be0\",\"confirmations\":28," +
            "\"scriptPubKey\":\"76a914d04b76146225d93e206f8c34b461403791b7264288ac\",\"vout\":0,\"address\":\"DQ8TVJGrVPQEYQiGMwnUvP15MdTFP8yBXJ\"," +
            "\"amount\":0.10100000000000001,\"path\":\"m\\/0\\/0\",\"locked\":false}],\"broadcastedOn\":1555153191,\"message\":null," +
            "\"id\":\"e72711ed-4ada-4ee3-9d60-deb2ed052f39\",\"version\":3,\"proposalSignaturePubKey\":null,\"payProUrl\":null," +
            "\"walletN\":1,\"feeLevel\":\"normal\",\"walletM\":1,\"feePerKb\":100000,\"createdOn\":1555153186,\"fee\":100000," +
            "\"network\":\"livenet\",\"coin\":\"xvg\",\"creatorId\":\"8830a04d48c0dcded327806fc903b0f9b5ada46d9a12e0796da40b80e5a2b72c\"," +
            "\"txid\":\"b92dcf62d353a25a456adaf6c2e2159747f78e7074d2afa3d5c7e659a8a4cee6\",\"walletId\":\"3547a0ad-2273-4403-ae38-dd0ecdf86d4f\"," +
            "\"raw\":\"0100000022c1b15c01e05be838fb1d94e7eee8a3fa969cf80a190eb073529b34ab628f256c8c932c44000000006b4830450221008c222a0edf83275e5849d62cb09e57554d96ab643d9ab7af26021f3f9921f8ba02201247b030df5f8f734c679abf1a4e5cb26e3e2824b142a7792f0ed2dc5faf456d0121031a661e0ee71dc72abcfe37d069bcf41b88448f6955ac75fdc4c6c9ea44480098ffffffff0180969800000000001976a91402175bb34e8df3dd2644221a6df2c564c4ff90db88ac00000000\"," +
            "\"inputPaths\":[\"m\\/0\\/0\"],\"actions\":[{\"type\":\"accept\",\"xpub\":\"ToEA6kpDTfS2mToqS7yg6xzX6kSj8spwrq611jkdGL4fFitpGg8s4uFC5WpQ5839tYMnSbkc59YB23w4sRw2jvpyygBbb9YAcSUqiRuCyicQVz4\"," +
            "\"signatures\":[\"30450221008c222a0edf83275e5849d62cb09e57554d96ab643d9ab7af26021f3f9921f8ba02201247b030df5f8f734c679abf1a4e5cb26e3e2824b142a7792f0ed2dc5faf456d\"]," +
            "\"copayerName\":\"{\\\"iv\\\":\\\"eB2o+MVCryZtGlx5DuXY9A==\\\",\\\"v\\\":1,\\\"iter\\\":1,\\\"ks\\\":128,\\\"ts\\\":64,\\\"mode\\\":\\\"ccm\\\",\\\"adata\\\":\\\"\\\",\\\"cipher\\\":\\\"aes\\\",\\\"ct\\\":\\\"1P2zc0PomM9GfWQDkZ4Aleyn4Q==\\\"}\"," +
            "\"copayerId\":\"8830a04d48c0dcded327806fc903b0f9b5ada46d9a12e0796da40b80e5a2b72c\",\"version\":\"1.0.0\"," +
            "\"createdOn\":1555153191,\"comment\":null}],\"requiredRejections\":1,\"amount\":10000000,\"timestamp\":1555153186," +
            "\"proposalSignaturePubKeySig\":null,\"addressType\":\"P2PKH\",\"customData\":null,\"proposalSignature\":\"304402200db38b10cf977e5aa4f142168a3846c90291741cb9b224f1758c73e674bfa59c02204cb4a07a435a71b5b38cb9b89f28a06063afd889737eb488b26ca88f18c5c40b\"," +
            "\"changeAddress\":{\"beRegistered\":null,\"coin\":\"xvg\",\"hasActivity\":null,\"network\":\"livenet\"," +
            "\"version\":\"1.0.0\",\"walletId\":\"3547a0ad-2273-4403-ae38-dd0ecdf86d4f\",\"address\":\"DQsYoSg3h78zMFiifGH3UfneLw7i1CAkmy\"," +
            "\"publicKeys\":[\"039d9f41b75ab3baaadd8f3e06b7a37797d84cf00bf358d89cb50efb172b101ad5\"],\"isChange\":true," +
            "\"type\":\"P2PKH\",\"createdOn\":1555153186,\"_id\":\"5cb1c122616c2628658f7d66\",\"path\":\"m\\/1\\/4\"}}"

        let jsonData: Data = responseJson.data(using: .utf8)!
        let response = try? JSONDecoder().decode(TxProposalResponse.self, from: jsonData)

        completion(response, nil, nil)
    }
}

class WalletClientMock: WalletClientProtocol {
    func createWallet(walletName: String, copayerName: String, m: Int, n: Int, options: WalletOptions?, completion: @escaping (Error?, String?) -> Void) {}
    func joinWallet(walletIdentifier: String, completion: @escaping (Error?) -> Void) {}
    func openWallet(completion: @escaping (Error?) -> Void) {}
    func scanAddresses(completion: @escaping (Error?) -> Void) {}
    func createAddress(completion: @escaping (Error?, AddressInfo?, CreateAddressErrorResponse?) -> Void) {}
    func getBalance(completion: @escaping (Error?, WalletBalanceInfo?) -> Void) {}
    func getMainAddresses(options: WalletAddressesOptions?, completion: @escaping (Error?, [AddressInfo]) -> ()) {}
    func getTxHistory(skip: Int?, limit: Int?, completion: @escaping ([TxHistory], Error?) -> Void) {}
    func getUnspentOutputs(address: String?, completion: @escaping ([UnspentOutput], Error?) -> Void) {}
    func getSendMaxInfo(completion: @escaping (SendMaxInfo?, Error?) -> Void) {}
    func createTxProposal(proposal: TxProposal, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {}
    func publishTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {}
    func signTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {}
    func broadcastTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {}
    func rejectTxProposal(txp: TxProposalResponse, completion: @escaping (Error?) -> Void) {}
    func deleteTxProposal(txp: TxProposalResponse, completion: @escaping (Error?) -> Void = {_ in }) {}
    func getTxProposals(completion: @escaping ([TxProposalResponse], Error?) -> Void) {}
    func resetServiceUrl(baseUrl: String) {}
    func watchRequestCredentialsForMethodPath(path: String) -> WatchRequestCredentials {
        return WatchRequestCredentials(url: "url", copayerId: "copayerid", signature: "signature")
    }
}
