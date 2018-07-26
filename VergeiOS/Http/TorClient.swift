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

                print(torController.isConnected)
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
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let torPath = "\(documentsDirectory)/Tor"
        
        do {
            try FileManager.default.createDirectory(atPath: torPath, withIntermediateDirectories: false, attributes: [
                FileAttributeKey.posixPermissions: 0o700
            ])
        } catch {
            print("Directory previously created. 🤷‍♀️")
        }
        
        return torPath
    }
    
    private func addControllerObserver(_ torController: TorController) {
        torController.addObserver(forCircuitEstablished: { established in
            if (!established) {
                return
            }
            print("established")
            self.startUrlSession(torController)
        })
    }
    
    private func startUrlSession(_ torController: TorController) {
        torController.getSessionConfiguration() { sessionConfig in
            print("sessionConfig")
            let session = URLSession(configuration: sessionConfig!)
            print(session.dataTask(with: URL(fileURLWithPath: "http://google.com")))
        }
    }
}
