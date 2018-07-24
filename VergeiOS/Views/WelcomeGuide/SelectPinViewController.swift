//
//  SelectPinViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 23-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SelectPinViewController: UIViewController, KeyboardDelegate {
    
    @IBOutlet weak var pinTextField: PinTextField!
    @IBOutlet weak var pinKeyboard: PinKeyboard!
    
    var pin: String = ""
    
    override func viewDidLoad() {
        self.pinKeyboard.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (UIDevice.current.userInterfaceIdiom != .pad) {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey) {
        if (keyboardKey.isKind(of: BackKey.self)) {
            self.pinTextField.removeCharacter()
            
            if (pin.count > 0) {
                pin = String(pin[..<pin.index(pin.endIndex, offsetBy: -1)])
            }
        } else {
            self.pinTextField.addCharacter()
            
            if (pin.count <= 6) {
                pin = "\(pin)\(input)"
            }
        }
        
        print(pin)
    }
    
    // Dismiss the view
    @IBAction func backToWelcome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
