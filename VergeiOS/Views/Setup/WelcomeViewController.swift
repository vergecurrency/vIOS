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

        // TODO: Create a Tor setup page and move this over.
        // Set Tor enabled as default.
        ApplicationManager.default.useTor = true
        // Now start Tor.
        TorClient.shared.start {}
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let navigationController = segue.destination as? UINavigationController else {
            return
        }

        ApplicationManager.default.reset()

        if let vc = navigationController.viewControllers.first as? SelectPinViewController {
            vc.segueIdentifier = segue.identifier
        }
    }
}

