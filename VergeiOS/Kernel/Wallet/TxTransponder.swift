//
// Created by Swen van Zanten on 15/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

class TxTransponder {

    enum Step: Int {
        case create = 0
        case publish = 1
        case sign = 2
        case broadcast = 3
    }

    typealias completionType = (_ txp: TxProposalResponse?, _ error: Error?) -> Void

    private var walletClient: WalletClient!
    private var completion: completionType!
    private var step: Step = .create

    public init(walletClient: WalletClient) {
        self.walletClient = walletClient
    }

    public func send(proposal: TxProposal, completion: @escaping completionType) {
        self.completion = completion

        // Create a tx proposal and start the sequence.
        walletClient.createTxProposal(proposal: proposal, completion: completionHandler)
    }

    private func progress(txp: TxProposalResponse) {
        switch step {
        case .publish:
            return walletClient.publishTxProposal(txp: txp, completion: completionHandler)
        case .sign:
            return walletClient.signTxProposal(txp: txp, completion: completionHandler)
        case .broadcast:
            return walletClient.broadcastTxProposal(txp: txp, completion: completionHandler)
        default:
            completionHandler(nil, NSError(domain: "Whoops", code: 500))
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
        default:
            NotificationCenter.default.post(name: .didCreateTx, object: self)
        }
    }

    private func completionHandler(_ txp: TxProposalResponse?, _ error: Error?) -> Void {
        // When we have an error we try again.
        if let error = error {
            print(error)
            DispatchQueue.main.async {
                self.completion(txp, error)
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
            self.completion(txp, error)
        }
    }
}
