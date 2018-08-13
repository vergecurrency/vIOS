//
//  ReceiveViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import QRCode

class ReceiveViewController: UIViewController {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var qrCode = QRCode("cBQFLyaV5o17Rpx424JGHbQjdffyQs7Atm")
        qrCode?.color = CIColor(cgColor: UIColor.primaryDark().cgColor)
        self.qrCodeImageView.image = (qrCode?.image)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
