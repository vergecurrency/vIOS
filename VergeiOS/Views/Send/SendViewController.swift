//
//  SendViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SendViewController: UIViewController, KeyboardDelegate {

    @IBOutlet weak var xvgAmount: UILabel!
    @IBOutlet weak var xvgAmountKeyboard: XvgAmountKeyboard!
    @IBOutlet weak var noBalanceView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.xvgAmountKeyboard.delegate = self
        self.noBalanceView.isHidden = false
        
        let _ = setTimeout(5) {
            self.noBalanceView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addRecipient(_ sender: Any) {
        
    }
    
    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey) {
        var xvg = self.xvgAmount.text!
        
        if (keyboardKey.isKind(of: BackKey.self)) {
            if xvg.count > 1 {
                xvg.removeLast()
            } else {
                xvg = "0"
            }
        } else {
            if (input == "." && xvg.contains(Character("."))) {
                return
            }
            
            if (xvg == "0") {
                xvg = ""
            }
            
            xvg.append(input)
        }
        
        self.xvgAmount.text = xvg
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
