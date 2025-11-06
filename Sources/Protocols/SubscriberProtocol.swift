//
//  ListenerProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 30/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

/// Protocol defining subscriber behavior
protocol SubscriberProtocol: AnyObject {
    /// Must return all Notification.Name → Selector mappings
    func getSubscribedEvents() -> [Notification.Name: Selector]
}

/// Default extension gives each subscriber a unique typeName
extension SubscriberProtocol {
    static var typeName: String {
        String(describing: Self.self)
    }
}
