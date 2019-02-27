//
//  InterfaceController.swift
//  VergeWatch Extension
//
//  Created by Ivan Manov on 1/23/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import WatchKit
import Foundation

class MainInterfaceController: WKInterfaceController {

    @IBOutlet var vergeTable: WKInterfaceTable!
    
    var priceRow: MainRowController?
    var walletRow: MainRowController?
    var qrCodeRow: MainRowController?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.prepareTable()
        
        StatisticsManager.shared.startUpdate()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUI),
                                               name: didUpdateStats,
                                               object: nil)
        
        self.updatePrice()
    }
    
    func prepareTable() {
        self.priceRow = nil
        self.walletRow = nil
        self.qrCodeRow = nil
        
        self.vergeTable.insertRows(at: IndexSet(integer: 0), withRowType: "MainRowPrice")
        self.vergeTable.insertRows(at: IndexSet(integer: 1), withRowType: "MainRowWallet")
        self.vergeTable.insertRows(at: IndexSet(integer: 2), withRowType: "MainRowQrCode")
        
        self.priceRow = vergeTable.rowController(at: 0) as? MainRowController;
        self.walletRow = vergeTable.rowController(at: 1) as? MainRowController;
        self.qrCodeRow = vergeTable.rowController(at: 2) as? MainRowController;
    }
    
    @objc func updateUI() {
        self.updatePrice()
        self.updateAmount()
        self.updateAddress()
    }
    
    private func updatePrice() {
        let lastStats = StatisticsManager.shared.lastStats
        let currency = StatisticsManager.shared.currency
        
        if self.priceRow != nil {
            if lastStats != nil {
                var color = UIColor.vergeGrey()
                var priceResult = String(format: "%.4f", lastStats!.price)
                
                priceResult = symbolForCurrency(currency: currency ?? "$") + priceResult
                
                var priceDiffResult = String(format: "%.2f%%", lastStats!.changepct24Hour)
                if (lastStats!.changepct24Hour > 0) {
                    priceDiffResult = "+" + priceDiffResult + " ▲"
                    color = UIColor.vergeGreen()
                } else if (lastStats!.changepct24Hour < 0) {
                    priceDiffResult = priceDiffResult + " ▼"
                    color = UIColor.vergeRed()
                }
                
                self.priceRow?.titleLabel.setText(priceResult)
                self.priceRow?.subtitleLabel.setTextColor(color)
                self.priceRow?.subtitleLabel.setText(priceDiffResult)
            } else {
                self.priceRow?.titleLabel.setText("Loading...")
                self.priceRow?.subtitleLabel.setText("")
            }
        }
    }
    
    private func updateAmount() {
        let lastStats = StatisticsManager.shared.lastStats
        let currency = StatisticsManager.shared.currency
        let amount = StatisticsManager.shared.amount
        
        if self.walletRow != nil {
            var title = "Need sync"
            var subtitle = ""
            
            if (amount != nil) {
                title = String.init(format: "%.2f XVG", (amount?.doubleValue ?? 0))
                
                if (lastStats != nil) {
                    let funds = (lastStats!.price * (amount?.doubleValue)!)
                    subtitle = String.init(format: "%@%.2f",
                                           self.symbolForCurrency(currency: currency ?? "USD"), funds)
                }
            }
            
            self.updateLabelTrunc(label: (self.walletRow?.titleLabel)!, with: title)
            self.walletRow?.subtitleLabel.setText(subtitle)
        }
    }
    
    private func updateAddress() {
        let address = StatisticsManager.shared.address
        
        if self.qrCodeRow != nil {
            self.qrCodeRow?.titleLabel.setText((address != nil) ? "Receive" : "Need sync...")
            self.updateLabelTrunc(label: (self.qrCodeRow?.subtitleLabel)!, with: address ?? "")
        }
    }
    
    private func updateLabelTrunc(label :WKInterfaceLabel, with text: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingMiddle
        let addressAttString = NSAttributedString(string: text,
                                                  attributes: [NSAttributedString.Key.paragraphStyle: paragraph])
        label.setAttributedText(addressAttString)
    }
    
    private func symbolForCurrency(currency: String) -> String {
        if (currency == "USD") {
            return "$"
        } else if (currency == "EUR") {
            return "€"
        } else if (currency == "RUB") {
            return "₽"
        } else {
            return currency
        }
    }
}
