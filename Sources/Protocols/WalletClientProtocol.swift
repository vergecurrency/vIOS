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
        options: Vws.WalletOptions?,
        completion: @escaping (Vws.WalletID?, Vws.WalletID.Error?, Error?) -> Void
    )
    // swiftlint:enable function_parameter_count

    func joinWallet(
        walletIdentifier: String,
        completion: @escaping (Vws.WalletJoin?, Vws.WalletJoin.Error?, Error?) -> Void
    )
    func openWallet(completion: @escaping (Vws.WalletStatus?, Vws.WalletStatus.Error?, Error?) -> Void)
    func scanAddresses(completion: @escaping (_ error: Error?) -> Void)

    func createAddress(
        completion: @escaping (
            _ error: Error?,
            _ address: Vws.AddressInfo?,
            _ createAddressErrorResponse: Vws.CreateAddressError?
        ) -> Void
    )

    func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: Vws.WalletBalanceInfo?) -> Void)

    func getMainAddresses(
        options: Vws.WalletAddressesOptions?,
        completion: @escaping (_ error: Error?, _ addresses: [Vws.AddressInfo]) -> Void
    )

    func getTxHistory(
        skip: Int?,
        limit: Int?,
        completion: @escaping ([Vws.TxHistory], Error?) -> Void
    )

    func getUnspentOutputs(
        address: String?,
        completion: @escaping ([Vws.UnspentOutput], Error?) -> Void
    )

    func getSendMaxInfo(completion: @escaping (Vws.SendMaxInfo?, Error?) -> Void)

    func createTxProposal(
        proposal: Vws.TxProposal,
        completion: @escaping (
            _ txp: Vws.TxProposalResponse?,
            _ errorResponse: Vws.TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    )

    func publishTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping (
            _ txp: Vws.TxProposalResponse?,
            _ errorResponse: Vws.TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    )

    func signTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping (
            _ txp: Vws.TxProposalResponse?,
            _ errorResponse: Vws.TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    )

    func broadcastTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping (
            _ txp: Vws.TxProposalResponse?,
            _ errorResponse: Vws.TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    )

    func rejectTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ error: Error?) -> Void)
    func deleteTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ error: Error?) -> Void)
    func getTxProposals(completion: @escaping (_ txps: [Vws.TxProposalResponse], _ error: Error?) -> Void)
    func resetServiceUrl(baseUrl: String)
    func watchRequestCredentialsForMethodPath(path: String) throws -> WatchRequestCredentials
}

extension WalletClientProtocol {
    func scanAddresses(completion: @escaping (_ error: Error?) -> Void = {_ in }) {
        self.scanAddresses(completion: completion)
    }

    public func deleteTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ error: Error?) -> Void = { _ in }) {
        self.deleteTxProposal(txp: txp, completion: completion)
    }
}
