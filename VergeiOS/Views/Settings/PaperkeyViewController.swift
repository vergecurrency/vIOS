//
// Created by Swen van Zanten on 26/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class PaperkeyViewController: UIViewController {

    @IBAction func showPaperkey(_ sender: Any) {
        let pinUnlockView = PinUnlockViewController.createFromStoryBoard()
        pinUnlockView.cancelable = true
        pinUnlockView.completion = { authenticated in
            pinUnlockView.dismiss(animated: true) {
                if authenticated {
                    self.performSegue(withIdentifier: "ShowPaperkey", sender: self)
                }
            }
        }

        present(pinUnlockView, animated: true)
    }

}
