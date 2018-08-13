//
//  SendViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {

    @IBOutlet weak var xvgCard: XVGCardImageView!
    @IBOutlet weak var noBalanceView: UIView!
    @IBOutlet weak var receipientTextField: SelectorButton!
    @IBOutlet weak var amountTextField: SelectorButton!
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noBalanceView.isHidden = false
        
        let _ = setTimeout(5) {
            self.noBalanceView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.xvgCard.alpha = 0.0
        self.xvgCard.center.y += 20.0
        
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            self.xvgCard.alpha = 1.0
            self.xvgCard.center.y -= 20.0
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "scanQRCode" {
            let vc = segue.destination as! ScanQRCodeViewController
            vc.sendViewController = self
        }
        
        if segue.identifier == "selectRecipient" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers.first as! SelectRecipientTableViewController
            vc.sendViewController = self
        }
        
        if segue.identifier == "setAmount" {
            let vc = segue.destination as! SetAmountViewController
            vc.sendViewController = self
        }
    }

}
