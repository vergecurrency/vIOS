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

    func completeLoading() {
        let identifier = WalletManager.default.setup ? "showWallet" : "showWelcomeView"

        self.performSegue(withIdentifier: identifier, sender: self)
    }

}
