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
    @IBOutlet weak var indicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView.layer.cornerRadius = 5.0
        indicatorView.clipsToBounds = true
    }
    
    func setStatus(_ status: TorStatusIndicator.status) {
        switch status {
        case .connected:
            indicatorView.backgroundColor = UIColor.vergeGreen()
        case .disconnected:
            indicatorView.backgroundColor = UIColor.orange
        case .turnedOff:
            indicatorView.backgroundColor = UIColor.vergeRed()
        }
        
        indicatorView.layoutIfNeeded()
    }
    
    func setHasNotch(_ hasNotch: Bool) {
        for contraint in containerView.constraints {
            if contraint.identifier == "containerViewHeight" {
                contraint.constant = hasNotch ? 54.0 : 34.0
            }
        }
        
        containerView.layoutIfNeeded()
    }
    
}

