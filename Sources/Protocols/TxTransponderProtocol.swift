//
//  TxTransponderProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

protocol TxTransponderProtocol {
    typealias CompletionType = (
        _ txp: TxProposalResponse?,
        _ errorResponse: TxProposalErrorResponse?,
        _ error: Error?
    ) -> Void

    func create(proposal: TxProposal, completion: @escaping CompletionType)
    func send(txp: TxProposalResponse, completion: @escaping CompletionType)
}
