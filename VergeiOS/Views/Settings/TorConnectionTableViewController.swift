//
//  TorConnectionTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 03/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TorConnectionTableViewController: UITableViewController {

    @IBOutlet weak var useTorSwitch: UISwitch!
    @IBOutlet weak var ipAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        useTorSwitch.setOn(WalletManager.default.useTor, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateIPAddress()
    }
    
    @IBAction func changeTorUsage(_ sender: UISwitch) {
        WalletManager.default.useTor = sender.isOn
        
        if sender.isOn {
            setIpAddressLabel("Loading...")
            
            TorClient.shared.start {
                self.updateIPAddress()
            }
        } else {
            TorClient.shared.resign()
            
            self.updateIPAddress()
            
            // Notify the whole application.
            NotificationCenter.default.post(name: .didTurnOffTor, object: self, userInfo: nil)
        }
    }
    
    func updateIPAddress() {
        setIpAddressLabel("Loading...")
        
        let url = URL(string: "https://api.ipify.org/?format=json")
        let task = TorClient.shared.session.dataTask(with: url!) { data, response, error in
            do {
                if data != nil {
                    let ipAddress = try JSONDecoder().decode(IpAddress.self, from: data!)
                    
                    self.setIpAddressLabel(ipAddress.ip)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func setIpAddressLabel(_ label: String) {
        DispatchQueue.main.async {
            self.ipAddressLabel.text = label
        }
    }

}
