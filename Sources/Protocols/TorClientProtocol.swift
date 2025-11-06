////
////  TorClientProtocol.swift
////  VergeiOS
////
////  Created by Swen van Zanten on 01/04/2020.
////  Copyright © 2020 Verge Currency. All rights reserved.
////
//
//import Foundation
//import Promises
//import Tor
//
//protocol TorClientProtocol {
//    var session: URLSession { get }
//
//    func start(completion: @escaping (Bool) -> Void)
//    func restart(completion: @escaping (Bool) -> Void)
//    func resign()
//    func getCircuits() -> Promise<[TorCircuit]>
//}
//
//extension TorClientProtocol {
//    func start(completion: @escaping (Bool) -> Void = { bool in }) {
//        return self.start(completion: completion)
//    }
//
//    func restart(completion: @escaping (Bool) -> Void = { bool in }) {
//        return self.restart(completion: completion)
//    }
//}
