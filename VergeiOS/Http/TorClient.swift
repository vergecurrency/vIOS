//
//  TorClient.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 25-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import NetworkExtension
import Tor

class TorClient {
    func start() {
        // Get the tor configuration.
        let config = self.createTorConfiguration()

        // Start a tor thread.
        let thread = TorThread(configuration: config)
        thread.start()

        let cookieUrl = config.dataDirectory?.appendingPathComponent("control_auth_cookie")

        do {
            let cookie = try Data(contentsOf: cookieUrl!)
            let torController = TorController(socketURL: config.controlSocket!)
            self.addControllerObserver(torController)

            torController.authenticate(with: cookie) { (success, error) in
                if (!success) {
                    return
                }

                self.addControllerObserver(torController)
            }
        } catch {
            print("Tor Failed at starting 🤷‍♀️")
        }
    }
    
    private func createTorConfiguration() -> TorConfiguration {
        let config = TorConfiguration()
        config.cookieAuthentication = true
        config.dataDirectory = URL(fileURLWithPath: self.createTorDirectory())
        config.controlSocket = config.dataDirectory?.appendingPathComponent("control_port")
        config.arguments = ["--allow-missing-torrc", "--ignore-missing-torrc"]
        
        return config
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
            let paths = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true)
            documentsDirectory = paths[0].split(separator: Character("/"))[0..<3].joined(separator: "/")
        } else {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            documentsDirectory = paths[0]
        }
        
        return "\(documentsDirectory)/tmp_tor"
    }
    
    private func addControllerObserver(_ torController: TorController) {
        torController.addObserver(forCircuitEstablished: { established in
            if (!established) {
                return
            }

            self.startUrlSession(torController)
        })
    }
    
    private func startUrlSession(_ torController: TorController) {
        torController.getSessionConfiguration() { sessionConfig in
            let _ = URLSession(configuration: sessionConfig!)
        }
    }
}
