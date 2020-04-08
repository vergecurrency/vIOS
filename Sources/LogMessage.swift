//
// Created by Swen van Zanten on 07/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation
import Logging

struct LogMessage {

    typealias Log = Logger.Message

    /// Migrations
    static let NoDeprecatedVWSEndpointsFound: Log = "no deprecated VWS endpoints found"

    /// Tor Client
    static let TorClientRestarting: Log = "tor client is restarting"
    static let TorClientNoRestartStillInOperation: Log = "tor couldn't restart cause it's still operational"
    static let TorClientControllerIsStillConnected: Log = "tor controller is still connected"
    static let TorClientResigning: Log = "tor client is resigning"
    static let TorClientNoResignStillInOperation: Log = "tor couldn't resign cause it's still operational"
    static let TorClientDisconnectingController: Log = "tor controller is disconnecting"
    static let TorClientCancellingThread: Log = "tor thread is cancelling"
    static let TorClientResigned: Log = "tor client resigned"
    static let TorClientGotURLSession: Log = "tor client got URL session"
    static let TorClientGotNoURLSession: Log = "tor client got no URL session"
    static let TorClientWaitedTooLongForURLSession: Log = "tor client waiting too for URL session"
    static let TorClientConnected: Log = "tor client connected"
    static let TorClientNotConnected: Log = "tor client not connected"
    static let TorClientNotAuthenticated: Log = "tor client not authenticated"
    static let TorClientCircuitEstablished: Log = "tor client circuit established"

    static func TorClientErrorDuringAuthentication(_ error: Error) -> Log {
        return Log("tor client error during authentication: \(error.localizedDescription)")
    }

    static func TorCLientErrorDuringConnection(_ error: Error) -> Log {
        return Log("tor client error during connection: \(error.localizedDescription)")
    }

    /// Wallet Ticker
    static let WalletTickerStartTwice: Log = "wallet ticker requested to start when already started"
    static let WalletTickerStartBeforeSetup: Log = "wallet ticker requested to start before application received setup status"
    static let WalletTickerStarted: Log = "wallet ticker started"
    static let WalletTickerStopped: Log = "wallet ticker stopped"
    static let WalletTickerFetchingWalletAmount: Log = "wallet ticker fetching wallet amount"
    static let WalletTickerSetWalletAmount: Log = "wallet ticker set wallet amount"
    static let WalletTickerFetchingTransactions: Log = "wallet ticker fetching transactions"
    static let WalletTickerReceivedTransactions: Log = "wallet ticker received transactions"

    static func WalletTickerWalletAmountError(_ error: Error) -> Log {
        return Log("wallet ticker amount error: \(error.localizedDescription)")
    }

    /// Fiat rate Ticker
    static let FiatRateTickerStartTwice: Log = "fiat ticker requested to start when already started"
    static let FiatRateTickerStartBeforeSetup: Log = "fiat ticker requested to start before application received setup status"
    static let FiatRateTickerStarted: Log = "fiat ticker started"
    static let FiatRateTickerStopped: Log = "fiat ticker stopped"
    static let FiatRateTickerFetchingRates: Log = "fiat rate ticker fetching rates"
    static let FiatRateTickerReceivedRates: Log = "fiat rate ticker received rates"

    /// Wallet client
    static let WalletClientRequestFired: Log = "wallet client request fired"

    static func WalletClientRequestError(_ error: Error) -> Log {
        return Log("wallet client request error: \(error.localizedDescription)")
    }

    /// Bitcore node client
    static let BitcoreNodeClientRequestFired: Log = "bitcore node client request fired"

}
