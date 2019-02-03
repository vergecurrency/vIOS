//
//  IntentsManager.swift
//  VergeiOS
//
//  Created by Ivan Manov on 2/1/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Intents

class IntentsManager: NSObject {
    
    @available(iOS 12.0, *)
    static func donateIntents() {
        let priceIntent = VergePriceIntent()
        priceIntent.suggestedInvocationPhrase = "Verge price"
        
        let interaction = INInteraction(intent: priceIntent, response: nil)
        
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    NSLog("Interaction donation failed: %@", error)
                } else {
                    NSLog("Successfully donated interaction")
                }
            }
        }
        
        let receiveFundsIntent = ReceiveFundsIntent()
        receiveFundsIntent.suggestedInvocationPhrase = "Receive Funds in Verge Currency"
        
        let receiveFundsInteraction = INInteraction(intent: receiveFundsIntent, response: nil)
        receiveFundsInteraction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    NSLog("Interaction donation failed: %@", error)
                } else {
                    NSLog("Successfully donated interaction")
                }
            }
        }
        
    }
}

