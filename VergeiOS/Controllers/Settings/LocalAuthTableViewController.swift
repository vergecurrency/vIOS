//
//  FaceIDTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 20-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import LocalAuthentication

class LocalAuthTableViewController: LocalizableTableViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var unlockWalletSwitch: UISwitch!
    @IBOutlet weak var sendXvgSwitch: UISwitch!

    var applicationRepository: ApplicationRepository!

    override func viewDidLoad() {
        super.viewDidLoad()

        if LAContext.available(type: .touchID) {
            headerImage.image = UIImage(named: "TouchID")
            navigationItem.title = "settings.localAuth.useTouchId".localized
        }

        unlockWalletSwitch.setOn(applicationRepository.localAuthForWalletUnlock, animated: false)
        sendXvgSwitch.setOn(applicationRepository.localAuthForSendingXvg, animated: false)
    }

    @IBAction func switchForUnlockingWallet(_ sender: UISwitch) {
        applicationRepository.localAuthForWalletUnlock = sender.isOn
    }

    @IBAction func switchForSendingXvg(_ sender: UISwitch) {
        applicationRepository.localAuthForSendingXvg = sender.isOn
    }

}
