//
//  TorClientProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 01/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

protocol TorClientProtocol {
    var session: URLSession { get }

    func start(completion: @escaping () -> Void)
    func restart()
    func resign()
    func turnedOff() -> Bool
}
