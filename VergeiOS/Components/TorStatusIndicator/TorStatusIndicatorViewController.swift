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

    var status: TorStatusIndicator.status = .turnedOff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView.layer.cornerRadius = 5.0
        indicatorView.clipsToBounds = true
    }
    
    func setStatus(_ status: TorStatusIndicator.status) {
        self.status = status
        switch status {
        case .connected:
            indicatorView.image = UIImage(named: "Locked")
            indicatorView.tintColor = ThemeManager.shared.secondaryDark()
        case .disconnected:
            indicatorView.image = UIImage(named: "Unlocked")
            indicatorView.tintColor = UIColor.orange
        case .turnedOff:
            indicatorView.image = UIImage(named: "Public")
            indicatorView.tintColor = ThemeManager.shared.vergeRed()
        case .error:
            indicatorView.image = UIImage(named: "ConnectionError")
            indicatorView.tintColor = ThemeManager.shared.vergeRed()
        }
        
        indicatorView.layoutIfNeeded()
    }
    
    func setHasNotch(_ hasNotch: Bool) {
        for contraint in containerView.constraints {
            if contraint.identifier == "containerViewHeight" {
                contraint.constant = hasNotch ? 54.0 : 32.0
            }
        }
        
        containerView.layoutIfNeeded()
    }
    
}

