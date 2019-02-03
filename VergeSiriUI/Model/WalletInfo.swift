//
//  WalletInfo.swift
//  VergeSiriUI
//
//  Created by Ivan Manov on 2/1/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class WalletInfo: NSObject {
    var cardImage: UIImage?
    
    static func fetchWalletInfo(completion: @escaping (WalletInfo?) -> Void) {
        let defaults = UserDefaults(suiteName: "group.org.verge")
        let data = defaults?.data(forKey: "wallet.receive.image.shared")
        
        let walletInfo = WalletInfo()
        
        if data != nil {
            let image = UIImage(data: data!)
            walletInfo.cardImage = image
        }
        
        completion(walletInfo)
    }
}
