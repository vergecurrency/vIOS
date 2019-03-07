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

    typealias completionType = (_ txp: TxProposalResponse?, _ errorResponse: TxProposalErrorResponse?, _ error: Error?) -> Void

    private var walletClient: WalletClient!
    private var completion: completionType!
    private var step: Step = .publish
    private var previousTxp: TxProposalResponse?

    public init(walletClient: WalletClient) {
        self.walletClient = walletClient
    }

    public func create(proposal: TxProposal, completion: @escaping completionType) {
        walletClient.createTxProposal(proposal: proposal, completion: completion)
    }

    public func send(txp: TxProposalResponse, completion: @escaping completionType) {
        self.completion = completion

        // Publish the tx proposal and start the sequence.
        walletClient.publishTxProposal(txp: txp, completion: completionHandler)
    }

    private func progress(txp: TxProposalResponse) {
        previousTxp = txp
        switch step {
        case .sign:
            return walletClient.signTxProposal(txp: txp, completion: completionHandler)
        case .broadcast:
            return walletClient.broadcastTxProposal(txp: txp, completion: completionHandler)
        default:
            completionHandler(nil, nil, NSError(domain: "Whoops", code: 500))
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
    ) -> Void {
        if let errorResponse = errorResponse {
            print(errorResponse)
            DispatchQueue.main.async {
                self.completion(self.previousTxp, errorResponse, error)
            }
            return
        }

        if let error = error {
            print(error)
            DispatchQueue.main.async {
                self.completion(txp, errorResponse, error)
            }
            return
        }

        // Notify the system of the successfull step.
        notifySystem()

        // When there is a next step progress the sequence.
        if let step = Step(rawValue: step.rawValue + 1) {
            self.step = step
            return progress(txp: txp!)
        }

        // Complete the sequence.
        DispatchQueue.main.async {
            self.step = .publish
            self.previousTxp = nil
            self.completion(txp, errorResponse, error)
        }
    }
}
