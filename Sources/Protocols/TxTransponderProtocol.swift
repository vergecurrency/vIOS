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
        _ txp: Vws.TxProposalResponse?,
        _ errorResponse: Vws.TxProposalErrorResponse?,
        _ error: Error?
    ) -> Void

    func create(proposal: Vws.TxProposal, completion: @escaping CompletionType)
    func send(txp: Vws.TxProposalResponse, completion: @escaping CompletionType)
}
