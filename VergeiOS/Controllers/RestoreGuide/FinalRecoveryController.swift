//
//  FinalRecoveryController.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 29.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class FinalRecoveryController: AbstractRestoreViewController {

    @IBOutlet weak var recoveryKeyView: UILabel!

    var applicationRepository: ApplicationRepository!
    var keys: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()

        recoveryKeyView.text = self.keys!.joined(separator: " ")
    }

    @IBAction func restoreWallet(_ sender: Any) {
        guard let keys = keys, ApplicationRepository.supportedMnemonicWordCounts.contains(keys.count) else {
            return self.present(UIAlertController.createInvalidMnemonicAlert(), animated: true)
        }

        // Save the mnemonic.
        applicationRepository.pendingRestoreMnemonic = keys
        applicationRepository.mnemonic = keys
        applicationRepository.passphrase = nil

        DispatchQueue.main.async {
            if self.applicationRepository.requiresSetupPassphrase(mnemonic: keys) {
                self.performSegue(withIdentifier: "finishRestoreGuide", sender: self)
            } else {
                let controller = UIStoryboard.createFromStoryboard(name: "Setup", type: FinishSetupViewController.self)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
