//
//  Subscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

class Subscriber: NSObject, SubscriberProtocol {
    func getSubscribedEvents() -> [Notification.Name: Selector] {
        fatalError("getSubscribedEvents() has not been implemented")
    }
}
