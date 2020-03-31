//
// Created by Swen van Zanten on 15/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

class TxTransponder {

    enum Step: Int {
        case publish = 0
        case sign = 1
        case broadcast = 2
    }

    typealias CompletionType = (
        _ txp: TxProposalResponse?,
        _ errorResponse: TxProposalErrorResponse?,
        _ error: Error?
    ) -> Void

    private var walletClient: WalletClientProtocol!
    private var completion: CompletionType!
    private var step: Step = .publish
    private var previousTxp: TxProposalResponse?

    public init(walletClient: WalletClientProtocol) {
        self.walletClient = walletClient
    }

    public func create(proposal: TxProposal, completion: @escaping CompletionType) {
        self.walletClient.createTxProposal(proposal: proposal, completion: completion)
    }

    public func send(txp: TxProposalResponse, completion: @escaping CompletionType) {
        self.completion = completion
        self.step = .publish

        // Publish the tx proposal and start the sequence.
        self.walletClient.publishTxProposal(txp: txp, completion: self.completionHandler)
    }

    private func progress(txp: TxProposalResponse) {
        previousTxp = txp
        switch step {
        case .sign:
            return self.walletClient.signTxProposal(txp: txp, completion: self.completionHandler)
        case .broadcast:
            return self.walletClient.broadcastTxProposal(txp: txp, completion: self.completionHandler)
        default:
            self.completionHandler(nil, nil, NSError(domain: "Whoops", code: 500))
        }
    }

    private func notifySystem() {
        switch self.step {
        case .publish:
            NotificationCenter.default.post(name: .didPublishTx, object: self)
        case .sign:
            NotificationCenter.default.post(name: .didSignTx, object: self)
        case .broadcast:
            NotificationCenter.default.post(name: .didBroadcastTx, object: self)
        }
    }

    private func completionHandler(
        _ txp: TxProposalResponse?,
        _ errorResponse: TxProposalErrorResponse?,
        _ error: Error?
    ) {
        if let errorResponse = errorResponse {
            NotificationCenter.default.post(name: .didAbortTransactionWithError, object: errorResponse)

            self.completion(self.previousTxp, errorResponse, error)
            return
        }

        if let error = error {
            NotificationCenter.default.post(name: .didAbortTransactionWithError, object: error)

            self.completion(txp, errorResponse, error)
            return
        }

        // Notify the system of the successfull step.
        self.notifySystem()

        // When there is a next step progress the sequence.
        if let step = Step(rawValue: step.rawValue + 1) {
            self.step = step
            return self.progress(txp: txp!)
        }

        // Complete the sequence.
        self.step = .publish
        self.previousTxp = nil
        self.completion(txp, errorResponse, error)
    }
}
