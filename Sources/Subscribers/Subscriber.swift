//
//  Subscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

//import Foundation
//
//class Subscriber: NSObject, SubscriberProtocol {
//     override init() {}
//
//    func getSubscribedEvents() -> [Notification.Name: Selector] {
//        fatalError("getSubscribedEvents() has not been implemented")
//    }
//}
import Foundation

/// Base class for all subscribers
class Subscriber: NSObject, SubscriberProtocol {
    override init() {
        super.init()
    }

    func getSubscribedEvents() -> [Notification.Name: Selector] {
        fatalError("getSubscribedEvents() has not been implemented")
    }
}
