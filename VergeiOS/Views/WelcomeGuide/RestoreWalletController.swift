//
//  RestoreWalletController.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 29.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class RestoreWalletController: AbstractRestoreViewController {
    
    @IBOutlet weak var paperKeyImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.paperKeyImage.alpha = 0.0
        self.paperKeyImage.center.y -= 30.0
        
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.paperKeyImage.alpha = 1.0
            self.paperKeyImage.center.y += 30.0
        }, completion: nil)
    }
    
    // Dismiss the view
    @IBAction func backToWelcome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
