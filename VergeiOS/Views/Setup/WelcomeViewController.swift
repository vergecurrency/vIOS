//
//  WelcomeViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 06-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Tor enabled as default.
        WalletManager.default.useTor = true
    }
}

