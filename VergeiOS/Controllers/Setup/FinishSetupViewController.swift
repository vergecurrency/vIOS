//
//  FinishSetupViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 29-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class FinishSetupViewController: AbstractPaperkeyViewController {

    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var termOneSwitch: UISwitch!
    @IBOutlet weak var termTwoSwitch: UISwitch!
    @IBOutlet weak var termThreeSwitch: UISwitch!
    @IBOutlet weak var createWalletButton: UIButton!

    @IBOutlet weak var walletCreationView: UIView!
    @IBOutlet weak var checklistImage: UIImageView!
    @IBOutlet weak var checklistDescription: UILabel!
    @IBOutlet weak var openWalletButton: RoundedButton!

    var applicationRepository: ApplicationRepository!
    var walletClient: WalletClient!
    var credentials: Credentials!

    var agreedWithTerms: Bool = false
    weak var interval: Timer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true

        self.createWalletButton.isEnabled = false
        self.createWalletButton.alpha = 0

        self.createWalletButton.isEnabled = false
        self.openWalletButton.alpha = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.interval?.invalidate()
    }

    @IBAction func showTermsOfUse(sender: Any) {
        present(UIAlertController.createShowTermsOfUseAlert(), animated: true)
    }

    @IBAction func termSwitched(sender: Any) {
        self.hideWalletButton(button: self.createWalletButton)

        if termOneSwitch.isOn && termTwoSwitch.isOn && termThreeSwitch.isOn {
            self.showWalletButton(button: self.createWalletButton)
        }
    }

    @IBAction func setupWallet(sender: Any) {
        termsView.isHidden = true
        walletCreationView.isHidden = false

        let mnemonic = self.applicationRepository.mnemonic ?? []
        let passphrase = self.applicationRepository.passphrase ?? ""

        self.credentials.reset(mnemonic: mnemonic, passphrase: passphrase)

        walletClient.createWallet(
            walletName: "ioswallet",
            copayerName: "iosuser",
            m: 1,
            n: 1,
            options: nil
        ) { error, secret in

            if (error != nil || secret == nil) {
                self.navigationController?.popViewController(animated: true)
                return
            }

            self.walletClient.joinWallet(walletIdentifier: self.applicationRepository.walletId!) { error in
                print(error ?? "")

                DispatchQueue.main.async {
                    self.animateProgress()
                }
            }
        }
    }

    func animateProgress() {
        var selectedImage = 0
        var images = [
            "ChecklistTwoItem",
            "ChecklistThreeItem",
            "CheckmarkCircle"
        ]

        interval = setInterval(1) {
            self.checklistImage.image = UIImage(named: images[selectedImage])
            selectedImage += 1

            if selectedImage == images.count {
                self.interval?.invalidate()

                self.checklistDescription.text = "setup.finish.congrats".localized
                self.showWalletButton(button: self.openWalletButton)
            }
        }
    }
    
    func showWalletButton(button: UIButton) {
        button.center.y += 30
        button.isEnabled = true

        UIView.animate(withDuration: 0.3) {
            button.alpha = 1
            button.center.y -= 30
        }
    }

    func hideWalletButton(button: UIButton) {
        UIView.animate(withDuration: 0.3) {
            button.alpha = 0
            button.isEnabled = false
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        NotificationCenter.default.post(name: .didSetupWallet, object: nil)
    }

}
