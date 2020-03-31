//
//  ListenerProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 30/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

protocol SubscriberProtocol: Subscriber {
    func getSubscribedEvents() -> [Notification.Name: Selector]
}

extension SubscriberProtocol {
    static var typeName: String {
        String(describing: self)
    }
}
