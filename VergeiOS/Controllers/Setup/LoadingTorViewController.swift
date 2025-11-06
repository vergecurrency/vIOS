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

        // Safely resolve the repository
        guard let applicationRepository = Application.container.resolve(ApplicationRepository.self) else {
            fatalError("ApplicationRepository is not registered in the container")
        }

        // ✅ Debug: Check setup status
        print("🔍 LoadingTorViewController: Checking setup status")
        print("  - Mnemonic count: \(applicationRepository.mnemonic?.count ?? 0)")
        print("  - Passphrase length: \(applicationRepository.passphrase?.count ?? 0)")
        print("  - PIN length: \(applicationRepository.pin.count)")
        print("  - Wallet ID: \(applicationRepository.walletId ?? "nil")")
        print("  - Setup status: \(applicationRepository.setup)")

        // Determine which segue to perform
        let identifier = applicationRepository.setup ? "showWallet" : "showWelcomeView"
        print("🔍 LoadingTorViewController: Navigating to \(identifier)")

        // Perform segue on the main thread
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: identifier, sender: self)
        }

        // Add observer for wallet disconnect
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDisconnectWallet),
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

    @objc func didDisconnectWallet(animated: Bool = false) {
        self.presentedViewController?.dismiss(animated: animated) {
            if self.presentedViewController?.isKind(of: PinUnlockViewController.self) == true {
                return self.didDisconnectWallet(animated: true)
            }

            self.performSegue(withIdentifier: "showWelcomeView", sender: self)
        }
    }
}
