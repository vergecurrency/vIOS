//
//  WelcomeViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 06-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    var applicationRepository: ApplicationRepository!
    var transactionManager: TransactionManager!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let navigationController = segue.destination as? UINavigationController else {
            return
        }

        self.transactionManager.removeAll()
        self.applicationRepository.reset()

        if let vc = navigationController.viewControllers.first as? SelectPinViewController {
            vc.segueIdentifier = segue.identifier
        }
    }
}
