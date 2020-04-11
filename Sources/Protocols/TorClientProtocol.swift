//
//  TorClientProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import Promises
import Tor

protocol TorClientProtocol {
    var session: URLSession { get }

    func start(completion: @escaping (Bool) -> Void)
    func restart()
    func resign()
    func turnedOff() -> Bool
    func getCircuits() -> Promise<[TorCircuit]>
}
