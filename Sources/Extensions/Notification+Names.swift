//
//  Notification+Names.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let didBootApplication = Notification.Name("didBootApplication")
    static let didSetupWallet = Notification.Name("didSetupWallet")
    static let didDisconnectWallet = Notification.Name("didDisconnectWallet")
    static let themeChanged = Notification.Name("themeChanged")
    static let didChangePinCharacterCount = Notification.Name("didChangePinCharacterCount")

    static let didReceiveFiatRatings = Notification.Name("didReceiveFiatRatings")
    static let didChangeCurrency = Notification.Name("didChangeCurrency")
    static let didChangeWalletAmount = Notification.Name("didChangeWalletAmount")
    static let didChangeReceiveAddress = Notification.Name("didChangeReceiveAddress")

    static let didFinishTorStart = Notification.Name("didFinishTorStart")
    static let didStartTorThread = Notification.Name("didStartTorThread")
    static let didConnectTorController = Notification.Name("didConnectTorController")
    static let didEstablishTorConnection = Notification.Name("didEstablishTorConnection")
    static let didResignTorConnection = Notification.Name("didResignTorConnection")
    static let didTurnOffTor = Notification.Name("didTurnOffTor")
    static let errorDuringTorConnection = Notification.Name("errorDuringTorConnection")
    static let didNotGetHiddenHttpSession = Notification.Name("didNotGetHiddenHttpSession")
    static let didResolveHiddenHttpSessionError = Notification.Name("didResolveHiddenHttpSessionError")

    static let didLoadWalletViewController = Notification.Name("didLoadWalletViewController")

    static let demandSendView = Notification.Name("demandSendView")
    static let didPublishTx = Notification.Name("didPublishTx")
    static let didSignTx = Notification.Name("didSignTx")
    static let didBroadcastTx = Notification.Name("didBroadcastTx")
    static let didReceiveTransaction = Notification.Name("didReceiveTransaction")
    static let didAbortTransactionWithError = Notification.Name("didAbortTransactionWithError")
    static let didResolveTransactionProposals = Notification.Name("didResolveTransactionProposals")
    static let didFindTransactionProposals = Notification.Name("didFindTransactionProposals")

    static let didChangeTheme = Notification.Name("didChangeTheme")

    static let didChangeSecureContent = Notification.Name("didChangeSecureContent")

    static let didDeviceShaken = Notification.Name("didDeviceShaken")
}
