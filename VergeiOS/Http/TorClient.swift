//
//  TorClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 25-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import Tor

class TorClient {

    // The shared tor client.
    static let shared = TorClient()

    private var config: TorConfiguration = TorConfiguration()
    private var thread: TorThread!
    private var controller: TorController!

    // Client status?
    private(set) var isOperational: Bool = false
    private var isConnected: Bool {
        return self.controller.isConnected
    }

    // The tor url session configuration.
    // Start with default config as fallback.
    private var sessionConfiguration: URLSessionConfiguration = .default

    // The tor client url session including the tor configuration.
    var session: URLSession {
        return URLSession(configuration: sessionConfiguration)
    }

    private init() {}

    private func setupThread() {
        config.options = [
            "DNSPort": "12345",
            "AutomapHostsOnResolve": "1",
            "AvoidDiskWrites": "1"
        ]
        config.cookieAuthentication = true
        config.dataDirectory = URL(fileURLWithPath: self.createTorDirectory())
        config.controlSocket = config.dataDirectory?.appendingPathComponent("cp")
        config.arguments = [
            "--allow-missing-torrc",
            "--ignore-missing-torrc",
            "--clientonly", "1",
            "--socksport", "39050",
            "--controlport", "127.0.0.1:39060",
        ]

        thread = TorThread(configuration: config)
    }

    // Start the tor client.
    func start(completion: @escaping () -> Void) {
        // If already operational don't start a new client.
        if isOperational || turnedOff() {
            return completion()
        }

        // Make sure we don't have a thread already.
        if thread == nil {
            setupThread()
        }

        // Initiate the controller.
        controller = TorController(socketURL: config.controlSocket!)
        
        // Start a tor thread.
        if thread.isExecuting == false {
            thread.start()

            NotificationCenter.default.post(name: .didStartTorThread, object: self)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Connect Tor controller.
            self.connectController(completion: completion)

            // Make sure the controller connects.
            var interval: Timer!
            interval = setInterval(4) {
                if !self.controller.isConnected || !self.isOperational {
                    print("Retry tor controller connection")
                    self.connectController(completion: completion)
                } else {
                    print("Remove tor controller connection interval")
                    interval.invalidate()
                }
            }
        }
    }

    // Resign the tor client.
    func resign() {
        if isOperational {
            sessionConfiguration = .default
            controller.disconnect()

            self.isOperational = false
            self.thread = nil

            NotificationCenter.default.post(name: .didResignTorConnection, object: self)

            return
        }

        // Retry in a sec.
        let _ = setTimeout(1) {
            self.resign()
        }
    }

    private func connectController(completion: @escaping () -> Void) {
        do {
            if !self.controller.isConnected {
                try self.controller?.connect()
                NotificationCenter.default.post(name: .didConnectTorController, object: self)
            }

            try self.authenticateController {
                print("Tor tunnel started! 🤩")

                NotificationCenter.default.post(name: .didEstablishTorConnection, object: self)

                completion()
            }
        } catch {
            print(error.localizedDescription)
            completion()
        }
    }

    private func authenticateController(completion: @escaping () -> Void) throws -> Void {
        let cookie = try Data(
            contentsOf: config.dataDirectory!.appendingPathComponent("control_auth_cookie"),
            options: NSData.ReadingOptions(rawValue: 0)
        )

        self.controller?.authenticate(with: cookie) { success, error in
            if let error = error {
                return print(error.localizedDescription)
            }

            var observer: Any? = nil
            observer = self.controller?.addObserver(forCircuitEstablished: { established in
                guard established else {
                    return
                }

                self.controller?.getSessionConfiguration() { sessionConfig in
                    self.sessionConfiguration = sessionConfig!

                    self.isOperational = true
                    completion()
                }

                self.controller?.removeObserver(observer)
            })
        }
    }
    
    private func createTorDirectory() -> String {
        let torPath = self.getTorPath()
        
        do {
            try FileManager.default.createDirectory(atPath: torPath, withIntermediateDirectories: false, attributes: [
                FileAttributeKey.posixPermissions: 0o700
            ])
        } catch {
            print("Directory previously created. 🤷‍♀️")
        }
        
        return torPath
    }
    
    private func getTorPath() -> String {
        var documentsDirectory = ""
        if Platform.isSimulator {
            let path = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first ?? ""
            documentsDirectory = "\(path.split(separator: Character("/"))[0..<2].joined(separator: "/"))/.tor_tmp"
        } else {
            documentsDirectory = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "")/t"
        }

        return documentsDirectory
    }
    
    func turnedOff() -> Bool {
        return !ApplicationManager.default.useTor
    }
}
