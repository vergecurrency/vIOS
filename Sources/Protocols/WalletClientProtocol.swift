//
//  WalletClientProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

protocol WalletClientProtocol {

    // swiftlint:disable function_parameter_count
    func createWallet(
        walletName: String,
        copayerName: String,
        m: Int,
        n: Int,
        options: WalletOptions?,
        completion: @escaping (_ error: Error?, _ secret: String?) -> Void
    )
    // swiftlint:enable function_parameter_count

    func joinWallet(walletIdentifier: String, completion: @escaping (_ error: Error?) -> Void)
    func openWallet(completion: @escaping (_ error: Error?) -> Void)
    func scanAddresses(completion: @escaping (_ error: Error?) -> Void)

    func createAddress(
        completion: @escaping (
            _ error: Error?,
            _ address: AddressInfo?,
            _ createAddressErrorResponse: CreateAddressErrorResponse?
        ) -> Void
    )

    func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: WalletBalanceInfo?) -> Void)

    func getMainAddresses(
        options: WalletAddressesOptions?,
        completion: @escaping (_ error: Error?, _ addresses: [AddressInfo]) -> Void
    )

    func getTxHistory(
        skip: Int?,
        limit: Int?,
        completion: @escaping (_ transactions: [TxHistory], Error?) -> Void
    )

    func getUnspentOutputs(
        address: String?,
        completion: @escaping (_ unspentOutputs: [UnspentOutput]) -> Void
    )

    func getSendMaxInfo(completion: @escaping (_ sendMaxInfo: SendMaxInfo?) -> Void)

    func createTxProposal(
        proposal: TxProposal,
        completion: @escaping (
            _ txp: TxProposalResponse?,
            _ errorResponse: TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    )

    func publishTxProposal(
        txp: TxProposalResponse,
        completion: @escaping (
            _ txp: TxProposalResponse?,
            _ errorResponse: TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    )

    func signTxProposal(
        txp: TxProposalResponse,
        completion: @escaping (
            _ txp: TxProposalResponse?,
            _ errorResponse: TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    )

    func broadcastTxProposal(
        txp: TxProposalResponse,
        completion: @escaping (
            _ txp: TxProposalResponse?,
            _ errorResponse: TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    )

    func rejectTxProposal(txp: TxProposalResponse, completion: @escaping (_ error: Error?) -> Void)
    func deleteTxProposal(txp: TxProposalResponse, completion: @escaping (_ error: Error?) -> Void)
    func getTxProposals(completion: @escaping (_ txps: [TxProposalResponse], _ error: Error?) -> Void)
    func resetServiceUrl(baseUrl: String)
    func watchRequestCredentialsForMethodPath(path: String) -> WatchRequestCredentials
}

extension WalletClientProtocol {
    func scanAddresses(completion: @escaping (_ error: Error?) -> Void = {_ in }) {
        self.scanAddresses(completion: completion)
    }

    public func deleteTxProposal(txp: TxProposalResponse, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        self.deleteTxProposal(txp: txp, completion: completion)
    }
}
