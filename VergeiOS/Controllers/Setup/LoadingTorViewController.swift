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

        let applicationRepository = Application.container.resolve(ApplicationRepository.self)!
        let identifier = applicationRepository.setup ? "showWallet" : "showWelcomeView"

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: identifier, sender: self)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDisconnectWallet(notification:)),
            name: .didDisconnectWallet,
            object: nil
        )
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWallet" {
            let vc = segue.destination as! PinUnlockViewController
            vc.fillPinFor = .wallet
            vc.completion = { authenticated in
                vc.performSegue(withIdentifier: "showWallet", sender: vc)
            }
        }
    }

    @objc func didDisconnectWallet(notification: Notification) {
        self.presentedViewController?.dismiss(animated: false) {
            self.performSegue(withIdentifier: "showWelcomeView", sender: self)
        }
    }
}
