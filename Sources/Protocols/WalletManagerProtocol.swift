//
//  WalletManagerProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26/10/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

protocol WalletManagerProtocol {
    func joinWallet(createWallet: Bool, completion: @escaping (_ error: Error?) -> Void)
    func createWallet(completion: @escaping (_ error: Error?) -> Void)
    func synchronizeWallet(completion: @escaping (_ error: Error?) -> Void)
}
