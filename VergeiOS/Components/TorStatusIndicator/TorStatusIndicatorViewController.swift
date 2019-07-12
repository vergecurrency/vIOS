//
//  TorIndicatorViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TorStatusIndicatorViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var indicatorView: UIImageView!

    var status: TorStatusIndicator.Status = .turnedOff

    override func viewDidLoad() {
        super.viewDidLoad()

        indicatorView.layer.cornerRadius = 5.0
        indicatorView.clipsToBounds = true
    }

    func setStatus(_ status: TorStatusIndicator.Status) {
        indicatorView.stopAnimating()
        indicatorView.animationImages = nil

        self.status = status
        switch status {
        case .connected:
            indicatorView.image = UIImage(named: "TorConnected")
            indicatorView.tintColor = UIColor(rgb: 0x764b92)
        case .disconnected:
            var imgListArray: [UIImage] = []
            for countValue in 1...4 {
                let strImageName: String = "TorConnecting-\(countValue)"
                let image = UIImage(named: strImageName)

                imgListArray.append(image!)
            }

            indicatorView.animationImages = imgListArray
            indicatorView.animationDuration = 1.5
            indicatorView.startAnimating()
            indicatorView.tintColor = UIColor.orange
        case .turnedOff:
            indicatorView.image = UIImage(named: "TorDisconnected")
            indicatorView.tintColor = ThemeManager.shared.vergeRed()
        case .error:
            indicatorView.image = UIImage(named: "TorConnectionError")
            indicatorView.tintColor = ThemeManager.shared.vergeRed()
        }

        indicatorView.layoutIfNeeded()
    }

    func setHasNotch(_ hasNotch: Bool) {
        for contraint in containerView.constraints
            where contraint.identifier == "containerViewHeight" {
            contraint.constant = hasNotch ? 54.0 : 33.0
        }

        containerView.layoutIfNeeded()
    }

}
