//
//  Notification+Names.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didReceiveFiatRatings = Notification.Name("didReceiveFiatRatings")
    static let didChangeCurrency = Notification.Name("didChangeCurrency")
    static let didChangeWalletAmount = Notification.Name("didChangeWalletAmount")
    static let didChangeReceiveAddress = Notification.Name("didChangeReceiveAddress")

    static let didStartTorThread = Notification.Name("didStartTorThread")
    static let didConnectTorController = Notification.Name("didConnectTorController")
    static let didEstablishTorConnection = Notification.Name("didEstablishTorConnection")
    static let didResignTorConnection = Notification.Name("didResignTorConnection")
    static let didTurnOffTor = Notification.Name("didTurnOffTor")
    static let errorDuringTorConnection = Notification.Name("errorDuringTorConnection")

    static let demandSendView = Notification.Name("demandSendView")
    static let didPublishTx = Notification.Name("didPublishTx")
    static let didSignTx = Notification.Name("didSignTx")
    static let didBroadcastTx = Notification.Name("didBroadcastTx")
    static let didReceiveTransaction = Notification.Name("didReceiveTransaction")
}
