//
//  ThemeSubscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

class ThemeSubscriber: Subscriber {
    @objc func didChangeTheme(notification: Notification) {
        PinUnlockViewController.storyBoardView = nil
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        [
            .didChangeTheme: #selector(didChangeTheme(notification:))
        ]
    }
}
