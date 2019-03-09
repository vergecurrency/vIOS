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
    
    private let kWatchStartConfirmed = NSNotification.Name(rawValue: "kWatchStartConfirmed").rawValue
    
    @IBOutlet var vergeTable: WKInterfaceTable!
    
    var priceRow: MainRowController?
    var walletRow: MainRowController?
    var qrCodeRow: MainRowController?
    var infoRow: MainRowController?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let startConfirmed = UserDefaults.standard.object(forKey: kWatchStartConfirmed) as? NSNumber
        if startConfirmed == nil {
            proceedConfirmation()
        } else {
            proccedStart()
        }
    }
    
    func proceedConfirmation() {
        let continueAction = WKAlertAction(title: "Confirm",
                                           style: .default,
                                           handler: {
                self.proccedStart()
                UserDefaults.standard.set(NSNumber.init(booleanLiteral: true),
                                          forKey: self.kWatchStartConfirmed)
        })
        
        presentAlert(withTitle: "Important",
                     message: "The Apple Watch Verge application can't do request over the Tor network making your requests visible to outsiders sniffing in.\n\nThis application only requests your balance and the current fiat ratings from the server. Make sure not to use this application if you only want to connect through Tor.\n\nPress \"Confirm\" if you want to continue",
                     preferredStyle: .actionSheet,
                     actions: [continueAction])
    }
    
    func proccedStart() {
        self.prepareTable()
        
        ConnectivityManager.shared.startUpdate()
        StatsProvider.shared.startUpdate()
        
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
        self.infoRow = nil
        
        self.vergeTable.insertRows(at: IndexSet(integer: 0), withRowType: "MainRowPrice")
        self.vergeTable.insertRows(at: IndexSet(integer: 1), withRowType: "MainRowWallet")
        self.vergeTable.insertRows(at: IndexSet(integer: 2), withRowType: "MainRowQrCode")
        self.vergeTable.insertRows(at: IndexSet(integer: 3), withRowType: "MainRowInfo")
        
        self.priceRow = vergeTable.rowController(at: 0) as? MainRowController;
        self.walletRow = vergeTable.rowController(at: 1) as? MainRowController;
        self.qrCodeRow = vergeTable.rowController(at: 2) as? MainRowController;
        self.infoRow = vergeTable.rowController(at: 3) as? MainRowController;
    }
    
    @objc func updateUI() {
        self.updatePrice()
        self.updateAmount()
        self.updateAddress()
    }
    
    private func updatePrice() {
        let lastStats = StatsProvider.shared.lastStats
        let currency = ConnectivityManager.shared.currency
        
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
        let lastStats = StatsProvider.shared.lastStats
        let currency = ConnectivityManager.shared.currency
        var amount = ConnectivityManager.shared.amount
        
        if self.walletRow != nil {
            var title = "Need sync"
            var subtitle = ""
            
            WatchWalletClient.shared.getBalance { (error, balanceInfo) in
                if balanceInfo != nil && error == nil {
                    amount = balanceInfo?.availableAmountValue
                }
                
                if (amount != nil) {
                    title = String.init(format: "%.2f XVG", (amount?.doubleValue ?? 0))
                    
                    if (lastStats != nil) {
                        let funds = (lastStats!.price * (amount?.doubleValue)!)
                        subtitle = String.init(format: "%@%.2f",
                                               self.symbolForCurrency(currency: currency ?? "USD"), funds)
                    }
                }
                
                self.walletRow?.titleLabel.setText(title)
                self.walletRow?.subtitleLabel.setText(subtitle)
            }
        }
    }
    
    private func updateAddress() {
        let address = ConnectivityManager.shared.address
        
        if self.qrCodeRow != nil {
            self.qrCodeRow?.titleLabel.setText((address != nil) ? "Receive" : "Need sync...")
            self.qrCodeRow?.subtitleLabel.setText(address?.truncated(limit: 12, position: .middle, leader: "..."))
        }
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

