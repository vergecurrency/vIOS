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
    var segueIdentifier: String? = "confirmPinWelcome"
    var completion: ((_ pin: String) -> Void)?
    
    override func viewDidLoad() {
        self.pinKeyboard.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (UIDevice.current.userInterfaceIdiom != .pad) {
            UIApplication.shared.statusBarStyle = .default
        }
        
        self.pin = ""
        self.pinTextField.reset()
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
                self.performSegue(withIdentifier: "confirmPin", sender: self)
            }
        }
    }
    
    // Dismiss the view
    @IBAction func backToWelcome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToSelection(segue: UIStoryboardSegue) {}

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "confirmPin") {
            if let vc = segue.destination as? ConfirmPinViewController {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                
                vc.previousPin = self.pin
                vc.segueIdentifier = segueIdentifier
                vc.completion = completion
            }
        }
     }
    
}
