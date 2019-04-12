//
//  TxTransponderTest.swift
//  VergeiOSTests
//
//  Created by Swen van Zanten on 12/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import XCTest
@testable import VergeiOS

class TxTransponderTest: XCTestCase {

    func testCreateATransaction() {
        let walletClient = TxTransponderTestWalletClient()
        let transponder = TxTransponder(walletClient: walletClient)
        
        let proposal = TxProposal(address: "jsad09asjd09jas9jds0", amount: 10.0, message: "What a beauty")
        
        transponder.create(proposal: proposal) { txp, txerror, error in
            print(txp)
        }
    }

}

class TxTransponderTestWalletClient: WalletClientProtocol {
    func createWallet(walletName: String, copayerName: String, m: Int, n: Int, options: WalletOptions?, completion: @escaping (Error?, String?) -> Void) {
        //
    }
    
    func joinWallet(walletIdentifier: String, completion: @escaping (Error?) -> Void) {
        //
    }
    
    func openWallet(completion: @escaping (Error?) -> Void) {
        //
    }
    
    func scanAddresses(completion: @escaping (Error?) -> Void) {
        //
    }
    
    func createAddress(completion: @escaping (Error?, AddressInfo?, CreateAddressErrorResponse?) -> Void) {
        //
    }
    
    func getBalance(completion: @escaping (Error?, WalletBalanceInfo?) -> Void) {
        //
    }
    
    func getMainAddresses(options: WalletAddressesOptions?, completion: @escaping ([AddressInfo]) -> Void) {
        //
    }
    
    func getTxHistory(skip: Int?, limit: Int?, completion: @escaping ([TxHistory]) -> Void) {
        //
    }
    
    func getUnspentOutputs(address: String?, completion: @escaping ([UnspentOutput]) -> Void) {
        //
    }
    
    func getSendMaxInfo(completion: @escaping (SendMaxInfo?) -> Void) {
        //
    }
    
    func createTxProposal(proposal: TxProposal, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {
        //
    }
    
    func publishTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {
        //
    }
    
    func signTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {
        //
    }
    
    func broadcastTxProposal(txp: TxProposalResponse, completion: @escaping (TxProposalResponse?, TxProposalErrorResponse?, Error?) -> Void) {
        //
    }
    
    func rejectTxProposal(txp: TxProposalResponse, completion: @escaping (Error?) -> Void) {
        //
    }
    
    func deleteTxProposal(txp: TxProposalResponse, completion: @escaping (Error?) -> Void) {
        //
    }
    
    func getTxProposals(completion: @escaping ([TxProposalResponse], Error?) -> Void) {
        //
    }
    
    func resetServiceUrl(baseUrl: String) {
        //
    }
    
    func watchRequestCredentialsForMethodPath(path: String) -> WatchRequestCredentials {
        return WatchRequestCredentials(url: "url", copayerId: "copayerid", signature: "signature")
    }
}
