//
//  PaperkeyShowViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 02/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import QRCode

class PaperkeyShowViewController: UIViewController {

    @IBOutlet weak var wordsLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!

    var mnemonic: String {
        return ApplicationRepository.default.mnemonic?.joined(separator: " ") ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        wordsLabel.text = mnemonic
    }

    @IBAction func switchView(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            var qr = QRCode(mnemonic)
            qr?.color = CIColor(cgColor: UIColor.primaryDark().cgColor)

            if qr != nil {
                qrImageView.image = qr!.image
            }
            break
        default:
            qrImageView.image = nil
        }
    }

    @IBAction func closeView(_ sender: Any) {
        dismiss(animated: true)
    }
}
