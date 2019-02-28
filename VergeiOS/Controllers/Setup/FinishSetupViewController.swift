//
//  FinishSetupViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 29-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class FinishSetupViewController: AbstractPaperkeyViewController {

    @IBOutlet weak var checklistImage: UIImageView!
    @IBOutlet weak var checklistDescription: UILabel!
    @IBOutlet weak var openWalletButton: RoundedButton!
    
    weak var interval: Timer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        self.openWalletButton.isHidden = true
        self.openWalletButton.alpha = 0
        self.openWalletButton.center.y += 30

        Credentials.shared.setSeed(
            mnemonic: ApplicationRepository.default.mnemonic!,
            passphrase: ApplicationRepository.default.passphrase!
        )

        WalletClient.shared.createWallet(
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

            WalletClient.shared.joinWallet(walletIdentifier: ApplicationRepository.default.walletId!) { error in
                print(error ?? "")

                DispatchQueue.main.async {
                    self.animateProgress()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.interval?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

                self.checklistDescription.text = "Your wallet is ready! Congratulations!"
                self.showWalletButton()
            }
        }
    }
    
    func showWalletButton() {
        UIView.animate(withDuration: 0.3) {
            self.openWalletButton.isHidden = false
            self.openWalletButton.alpha = 1
            self.openWalletButton.center.y -= 30
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        ApplicationRepository.default.setup = true

        FiatRateTicker.shared.start()
        WalletTicker.shared.start()
    }

}
