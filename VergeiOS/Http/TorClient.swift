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
    func startt() {
        let dataDirectory = URL(string: NSTemporaryDirectory())
        let controlSocket = dataDirectory?.appendingPathComponent("control_port")
        
        let controller = TorController(socketURL: controlSocket!)
        controller.addObserver(forCircuitEstablished: { (established) in
            print(established)
        })
        
        do {
            try controller.connect()
        } catch {
            print("Failed")
        }
    }
    
    func start() {
        let config = TorConfiguration()
        config.cookieAuthentication = true
        config.dataDirectory = URL(string: NSTemporaryDirectory())
        config.controlSocket = config.dataDirectory?.appendingPathComponent("control_port")
        config.arguments = ["--allow-missing-torrc", "--ignore-missing-torrc"]
        
        let thread = TorThread(configuration: config)
        thread.start()
        
        let cookieUrl = config.dataDirectory?.appendingPathComponent("control_auth_cookie")
        do {
            let cookie = try Data(contentsOf: cookieUrl!)
            let torController = TorController(socketURL: config.controlSocket!)

            torController.authenticate(with: cookie) { (success, error) in
                print(success)
                print("hello")

                torController.addObserver(forCircuitEstablished: { established in
                    print("established")
                    print(established)
                })
            }
        } catch {
            print("Failed")
        }
    }
}
