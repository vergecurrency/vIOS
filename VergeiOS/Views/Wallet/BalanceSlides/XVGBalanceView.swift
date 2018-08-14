//
//  XVGBalanceView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 04-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class XVGBalanceView: BalanceSlide {
    
    @IBOutlet weak var valueLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setWalletAmount()
    }
    
    private func setWalletAmount() {
        self.valueLabel.text = WalletManager.default.amount.toCurrency(currency: "XVG")
    }
    
}
