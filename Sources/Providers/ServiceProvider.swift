//
//  ServiceProvider.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Swinject

class ServiceProvider: ServiceProviderProtocol {

    let container: Container

    required init(container: Container) {
        self.container = container
    }

    func boot() {}

    func register() {}
}

protocol ServiceProviderProtocol {

    init(container: Container)
    func boot()
    func register()

}
