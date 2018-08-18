//
//  FiatBalanceView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 04-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class FiatBalanceView: BalanceSlide {
    
    @IBOutlet weak var valueLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        observePriceChange()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        observePriceChange()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setStats()
    }
    
    private func observePriceChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStats(notification:)),
            name: .didReceiveStats,
            object: nil
        )
    }
    
    @objc private func didReceiveStats(notification: Notification? = nil) {
        setStats()
    }
    
    func setStats() {
        DispatchQueue.main.async {
            if let xvgInfo = PriceTicker.shared.xvgInfo {
                let walletAmount = WalletManager.default.amount
                self.valueLabel.text = NSNumber(value: walletAmount.doubleValue * xvgInfo.raw.price).toCurrency()
            }
        }
    }

}
