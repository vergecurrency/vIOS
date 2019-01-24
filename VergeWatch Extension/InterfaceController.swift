//
//  InterfaceController.swift
//  VergeWatch Extension
//
//  Created by Ivan Manov on 1/23/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var priceLabel: WKInterfaceLabel!
    @IBOutlet var priceDiffLabel: WKInterfaceLabel!
    @IBOutlet var priceDiffTypeLabel: WKInterfaceLabel!
    @IBOutlet var priceLowLabel: WKInterfaceLabel!
    @IBOutlet var priceHighLabel: WKInterfaceLabel!
    @IBOutlet var priceMetaGroup: WKInterfaceGroup!
    
    var lastStats: Statistics?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.priceLabel.setText("Getting data...")
        self.priceMetaGroup.setHidden(true)
        
        self.proceedResults()
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
            self.proceedResults()
        }
    }
    
    func proceedResults() {
        self.getStatsForCurrency(currency: "USD") { (stats) in
            if (stats != nil) {
                self.lastStats = stats
                self.updateUI()
            }
        }
    }
    
    func updateUI() {
        if (self.lastStats != nil) {
            self.priceMetaGroup.setHidden(false)
            
            let priceResult = String(format: "$%.4f", self.lastStats!.price)
            self.priceLabel.setText(priceResult)
            
            var priceDiffResult = String(format: "%.2f%%", self.lastStats!.changepct24Hour)
            if (self.lastStats!.changepct24Hour > 0) {
                priceDiffResult = "+" + priceDiffResult + " ▲"
                self.priceDiffLabel.setTextColor(UIColor.vergeGreen())
            } else if (self.lastStats!.changepct24Hour < 0) {
                priceDiffResult = priceDiffResult + " ▼"
                self.priceDiffLabel.setTextColor(UIColor.vergeRed())
            } else {
                self.priceDiffLabel.setTextColor(UIColor.vergeGrey())
            }
            self.priceDiffLabel.setText(priceDiffResult)
            
            
            let priceHighResult = String(format: "$%.4f", self.lastStats!.high24Hour)
            self.priceHighLabel.setText(priceHighResult)
            
            let priceLowResult = String(format: "$%.4f", self.lastStats!.low24Hour)
            self.priceLowLabel.setText(priceLowResult)
            
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func getStatsForCurrency(currency: String, completion: @escaping (_ result: Statistics?) -> Void) {
        let url = URL(string: "\(Config.priceDataEndpoint)\(currency)")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if let data = data {
                do {
                    let statistics = try JSONDecoder().decode(Statistics.self, from: data)
                    completion(statistics)
                } catch {
                    print("Error info: \(error)")
                    completion(nil)
                }
            } else if let _ = error {
                completion(nil)
            }
        }
        
        task.resume()
    }
}
