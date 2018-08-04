//
//  PinUnlockViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 02-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PinUnlockViewController: UIViewController, KeyboardDelegate {

    @IBOutlet weak var pinKeyboard: PinKeyboard!
    @IBOutlet weak var pinTextField: PinTextField!
    
    var pin = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .default

        self.pinKeyboard.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey) {
        if (keyboardKey.isKind(of: BackKey.self)) {
            self.pinTextField.removeCharacter()
            
            if (pin.count > 0) {
                pin = String(pin[..<pin.index(pin.endIndex, offsetBy: -1)])
            }
        } else {
            self.pinTextField.addCharacter()
            
            if (pin.count < self.pinTextField.pinCharacterCount) {
                pin = "\(pin)\(input)"
            }
            
            // When all pins are set.
            if (pin.count == self.pinTextField.pinCharacterCount) {
                self.performSegue(withIdentifier: "showWallet", sender: self)
            }
        }
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
