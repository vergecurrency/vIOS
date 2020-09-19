//
//  TorClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 25-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import Tor
import Promises
import Logging

class TorClient: TorClientProtocol, HiddenClientProtocol {
    enum Error: Swift.Error {
        case controllerNotSet
        case notAuthenticated
        case notOperational
        case waitedTooLongForConnection
    }

    private let applicationRepository: ApplicationRepository
    private let log: Logging.Logger

    private var config: TorConfiguration = TorConfiguration()
    private var thread: TorThread?
    private var controller: TorController!

    // Client status?
    private(set) var isOperational: Bool = false
    private var isConnected: Bool {
        return self.controller?.isConnected ?? false
    }

    private var turnedOff: Bool {
        return !self.applicationRepository.useTor
    }

    // The tor url session configuration.
    // Start with default config as fallback.
    private var sessionConfiguration: URLSessionConfiguration = .default

    // The tor client url session including the tor configuration.
    internal var session: URLSession {
        self.sessionConfiguration.httpAdditionalHeaders = ["User-Agent": UUID().uuidString]

        if self.isOperational {
            self.sessionConfiguration.connectionProxyDictionary = [
                "SOCKSEnable": true,
                kCFStreamPropertySOCKSProxyHost: "localhost",
                kCFStreamPropertySOCKSProxyPort: 39050,
                kCFStreamPropertySOCKSUser: "verge",
                kCFStreamPropertySOCKSPassword: "verge"
            ]
        }

        return URLSession(configuration: self.sessionConfiguration)
    }

    public init(applicationRepository: ApplicationRepository, log: Logging.Logger) {
        self.applicationRepository = applicationRepository
        self.log = log
    }

    private func setupThread() {
        #if DEBUG
            let log_loc = "notice stdout"
        #else
            let log_loc = "notice file /dev/null"
        #endif

        self.config.cookieAuthentication = true
        self.config.dataDirectory = URL(fileURLWithPath: self.createDataDirectory())
        self.config.controlSocket = self.config.dataDirectory?.appendingPathComponent("cp")
        self.config.arguments = [
            "--allow-missing-torrc",
            "--ignore-missing-torrc",
            "--ClientOnly", "1",
            "--AvoidDiskWrites", "1",
            "--SocksPort", "127.0.0.1:39050",
            "--ControlPort", "127.0.0.1:39060",
            "--Log", log_loc,
            "--GeoIPFile", Bundle.main.path(forResource: "geoip", ofType: nil) ?? "",
            "--GeoIPv6File", Bundle.main.path(forResource: "geoip6", ofType: nil) ?? "",
        ]

        self.thread = TorThread(configuration: self.config)
    }

    func start(completion: @escaping (Bool) -> Void = { bool in }) {
        // If already operational don't start a new client.
        if self.isOperational || self.turnedOff {
            NotificationCenter.default.post(name: .didFinishTorStart, object: self)

            return completion(true)
        }

        // Make sure we don't have a thread already.
        if self.thread == nil {
            self.setupThread()
        }

        guard let controlSocket = self.config.controlSocket else {
            self.log.error("tor client control socket not set")

            NotificationCenter.default.post(name: .errorDuringTorConnection, object: nil)

            return completion(false)
        }

        // Initiate the controller.
        self.controller = TorController(socketURL: controlSocket)

        // Start a tor thread.
        if (self.thread?.isExecuting ?? false) == false {
            self.thread?.start()

            NotificationCenter.default.post(name: .didStartTorThread, object: self)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connectController(self.controller) { success in
                if success {
                    self.log.info("tor client connected")

                    NotificationCenter.default.post(name: .didFinishTorStart, object: self)
                }

                completion(success)
            }
        }
    }

    func restart(completion: @escaping (Bool) -> Void = { bool in }) {
        self.log.info("tor client is restarting")

        self.resign()

        NotificationCenter.default.post(name: .didResignTorConnection, object: self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.start(completion: completion)
        }
    }

    func resign() {
        self.log.info("tor client is resigning")

        if !self.isOperational {
            return self.log.warning("tor couldn't resign cause it's still operational")
        }

        self.controller.disconnect()
        self.controller = nil
        self.thread?.cancel()
        self.thread = nil
        self.isOperational = false
        self.sessionConfiguration = .default

        self.log.info("tor client resigned")

        NotificationCenter.default.post(name: .didTurnOffTor, object: self)
    }

    func getURLSession() -> Promise<URLSession> {
        return Promise { fulfill, reject in
            if self.isOperational || self.turnedOff {
                self.log.debug("tor client using \(self.turnedOff ? "default" : "TOR") url session")

                return fulfill(self.session)
            }

            let started: DispatchTime = .now()
            let _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if self.isOperational {
                    timer.invalidate()

                    self.log.info("tor client using TOR url session")

                    return fulfill(self.session)
                }

                // Wait a full minute to conclude its not gonna happen.
                if DispatchTime.now().uptimeNanoseconds > (started.uptimeNanoseconds + (60 * 1000000000)) {
                    timer.invalidate()

                    self.log.error("tor client waiting too for URL session")

                    return reject(Error.waitedTooLongForConnection)
                }
            }
        }
    }

    func getCircuits() -> Promise<[TorCircuit]> {
        return Promise { fulfill, reject in
            if !self.isOperational {
                return reject(Error.notOperational)
            }
            
            self.controller.getCircuits { circuits in
                fulfill(circuits)
            }
        }
    }

    private func connectController(_ controller: TorController, completion: @escaping (Bool) -> Void) {
        do {
            if !controller.isConnected {
                try controller.connect()
                NotificationCenter.default.post(name: .didConnectTorController, object: self)
            }

            try self.authenticateController(controller, completion: completion)
        } catch {
            self.log.error("tor client error during connection: \(error.localizedDescription)")

            NotificationCenter.default.post(name: .errorDuringTorConnection, object: error)

            completion(false)
        }
    }

    private func authenticateController(_ controller: TorController, completion: @escaping (Bool) -> Void) throws {
        let cookie = try Data(
            contentsOf: config.dataDirectory!.appendingPathComponent("control_auth_cookie"),
            options: NSData.ReadingOptions(rawValue: 0)
        )

        controller.authenticate(with: cookie) { authenticated, error in
            if let error = error {
                self.log.error("tor client error during authentication: \(error.localizedDescription)")

                NotificationCenter.default.post(name: .errorDuringTorConnection, object: error)

                return completion(false)
            }

            if !authenticated {
                self.log.error("tor client not authenticated")

                NotificationCenter.default.post(name: .errorDuringTorConnection, object: Error.notAuthenticated)

                return completion(false)
            }

            var observer: Any?
            observer = controller.addObserver(forCircuitEstablished: { established in
                if !established {
                    return self.log.notice("tor client not connected")
                }

                self.log.info("tor client circuit established")

                controller.getSessionConfiguration { sessionConfig in
                    guard let session = sessionConfig else {
                        self.log.error("tor client got no URL session")

                        return completion(false)
                    }

                    self.log.info("tor client got URL session")

                    NotificationCenter.default.post(name: .didEstablishTorConnection, object: self)

                    self.sessionConfiguration = session
                    self.isOperational = true
                    completion(true)
                }

                self.controller?.removeObserver(observer)
            })
        }
    }

    private func createDataDirectory() -> String {
        let path = self.getPath()
        var isDirectory = ObjCBool(true)
        
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            return path
        }

        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: [
                FileAttributeKey.posixPermissions: 0o700
            ])

            self.log.info("Tor data directory created")
        } catch {
            self.log.error("Tor data directory couldn't be created: \(error.localizedDescription)")
        }

        return path
    }

    private func getPath() -> String {
        var documentsDirectory = ""
        if Platform.isSimulator {
            let path = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first ?? ""
            documentsDirectory = "\(path.split(separator: Character("/"))[0..<2].joined(separator: "/"))/.tor_tmp"
        } else {
            documentsDirectory =
            "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "")/t"
        }

        return documentsDirectory
    }
}
