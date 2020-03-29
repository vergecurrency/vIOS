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

        self.indicatorView.layer.cornerRadius = 5.0
        self.indicatorView.clipsToBounds = true
        self.indicatorView.isUserInteractionEnabled = false
    }

    func setStatus(_ status: TorStatusIndicator.Status) {
        self.indicatorView.stopAnimating()
        self.indicatorView.animationImages = nil

        self.status = status
        switch status {
        case .connected:
            self.indicatorView.image = UIImage(named: "TorConnected")
            self.indicatorView.tintColor = UIColor(rgb: 0x764b92)
        case .disconnected:
            var imgListArray: [UIImage] = []
            for countValue in 1...4 {
                let strImageName: String = "TorConnecting-\(countValue)"
                let image = UIImage(named: strImageName)

                imgListArray.append(image!)
            }

            self.indicatorView.animationImages = imgListArray
            self.indicatorView.animationDuration = 1.5
            self.indicatorView.startAnimating()
            self.indicatorView.tintColor = UIColor.orange
        case .turnedOff:
            self.indicatorView.image = UIImage(named: "TorDisconnected")
            self.indicatorView.tintColor = ThemeManager.shared.vergeRed()
        case .error:
            self.indicatorView.image = UIImage(named: "TorConnectionError")
            self.indicatorView.tintColor = ThemeManager.shared.vergeRed()
        }

        self.indicatorView.layoutIfNeeded()
    }

    func setHasNotch(_ hasNotch: Bool) {
        for contraint in self.containerView.constraints
            where contraint.identifier == "containerViewHeight" {
            contraint.constant = hasNotch ? 54.0 : 33.0
        }

        self.containerView.layoutIfNeeded()
    }

}
