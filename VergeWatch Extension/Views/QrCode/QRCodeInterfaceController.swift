//
//  PriceInterfaceController.swift
//  VergeWatch Extension
//
//  Created by Ivan Manov on 1/27/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import WatchKit

class QRCodeInterfaceController: WKInterfaceController {
    @IBOutlet var image: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateQr),
                                               name: didUpdateAddress,
                                               object: nil)
        updateQr()
    }
    
    @objc func updateQr() {
        if ConnectivityManager.shared.qrCode != nil {
            image.setImage(UIImage.init(data: ConnectivityManager.shared.qrCode!))
        }
    }
}
