//
//  FaceIDTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 20-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import LocalAuthentication

class LocalAuthTableViewController: UITableViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var unlockWalletSwitch: UISwitch!
    @IBOutlet weak var sendXvgSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        if LAContext.available(type: .touchID) {
            headerImage.image = UIImage(named: "TouchID")
            navigationItem.title = "Use Touch ID"
        }

        unlockWalletSwitch.setOn(ApplicationRepository.default.localAuthForWalletUnlock, animated: false)
        sendXvgSwitch.setOn(ApplicationRepository.default.localAuthForSendingXvg, animated: false)
    }

    @IBAction func switchForUnlockingWallet(_ sender: UISwitch) {
        ApplicationRepository.default.localAuthForWalletUnlock = sender.isOn
    }
    
    @IBAction func switchForSendingXvg(_ sender: UISwitch) {
        ApplicationRepository.default.localAuthForSendingXvg = sender.isOn
    }
    
}
