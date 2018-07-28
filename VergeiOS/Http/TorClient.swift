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
    
    static let shared = TorClient()
    
    var session: URLSession?
    
    var connectionCompletion: ((_ connected: Bool) -> Void?)? = nil
    
    func start() {
        // Get the tor configuration.
        let config = self.createTorConfiguration()
        
        // Create the tor controller.
        let torController = TorController(socketURL: config.controlSocket!)
        
        // Start a tor thread.
        let thread = TorThread(configuration: config)
        thread.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            do {
                try torController.connect()
                let cookie = try Data(contentsOf:
                    config.dataDirectory!.appendingPathComponent("control_auth_cookie"), options: NSData.ReadingOptions(rawValue: 0)
                )
                
                torController.authenticate(with: cookie, completion: { (success, error) -> Void in
                    if let error = error {
                        return print(error.localizedDescription)
                    }
                    
                    self.addControllerObserver(torController)
                })
            } catch {
                print("Tor can't be started. 🤷‍♀️")
            }
        }
    }
    
    func observeConnection(completion: @escaping (_ connected: Bool) -> Void) {
        self.connectionCompletion = completion
    }
    
    private func createTorConfiguration() -> TorConfiguration {
        let config = TorConfiguration()
        config.options = ["DNSPort": "12345", "AutomapHostsOnResolve": "1", "SocksPort": "9050", "AvoidDiskWrites": "1"]
        config.cookieAuthentication = true
        config.dataDirectory = URL(fileURLWithPath: self.createTorDirectory())
        config.controlSocket = config.dataDirectory?.appendingPathComponent("control_port")
        config.arguments = ["--ignore-missing-torrc"]
        
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
            let path = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first ?? ""
            documentsDirectory = "\(path.split(separator: Character("/"))[0..<2].joined(separator: "/"))/.tor_tmp"
        } else {
            documentsDirectory = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "")/Tor"
        }

        return documentsDirectory
    }
    
    private func addControllerObserver(_ torController: TorController) {
        var observer: Any? = nil
        observer = torController.addObserver(forCircuitEstablished: { (established) -> Void in
            guard established else {
                return
            }
            
            torController.removeObserver(observer)
            
            self.startUrlSession(torController)
            
            print("Tor tunnel started! 🤩")
        })
    }
    
    private func startUrlSession(_ torController: TorController) {
        torController.getSessionConfiguration() { sessionConfig in
            self.session = URLSession(configuration: sessionConfig!)
            self.connectionCompletion!(true)
        }
    }
}

func tor() -> URLSession {
    return TorClient.shared.session ?? URLSession(configuration: .default)
}

