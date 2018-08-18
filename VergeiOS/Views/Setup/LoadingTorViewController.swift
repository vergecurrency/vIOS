//
//  LoadingTorViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 28-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class LoadingTorViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TorClient.shared.observeConnection { connected in
            if (!connected) {
                print("Whoops! Tor couldn't connect! 🤦‍♀️")
            }
            
            // Here we can determine whether to show
            // the wallet or the welcome guide.
            DispatchQueue.main.sync {
                // Start price ticker
                PriceTicker.shared.start()
                
                let identifier = WalletManager.default.setup ? "showWallet" : "showWelcomeView"
                
                self.performSegue(withIdentifier: identifier, sender: self)
            }
        }
    }

}
