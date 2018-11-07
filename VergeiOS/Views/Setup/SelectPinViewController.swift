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
    var segueIdentifier: String?
    var completion: ((_ pin: String) -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (UIDevice.current.userInterfaceIdiom != .pad) {
            return .default
        }
        
        return .lightContent
    }
    
    override func viewDidLoad() {
        pinKeyboard.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pin = ""
        pinTextField.reset()
    }
    
    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey) {
        if (keyboardKey.isKind(of: BackKey.self)) {
            pinTextField.removeCharacter()
            
            if (pin.count > 0) {
                pin = String(pin[..<pin.index(pin.endIndex, offsetBy: -1)])
            }
        } else {
            pinTextField.addCharacter()
            
            if (pin.count < pinTextField.pinCharacterCount) {
                pin = "\(pin)\(input)"
            }
            
            // When all pins are set.
            if (pin.count == pinTextField.pinCharacterCount) {
                performSegue(withIdentifier: "confirmPin", sender: self)
            }
        }
    }
    
    @IBAction func showSettings(_ sender: Any) {
        let settings = UIAlertController(title: "Choose a PIN size", message: nil, preferredStyle: .actionSheet)

        let digitCounts = [4, 5, 6, 7, 8]
        for count in digitCounts {
            let action = UIAlertAction(title: "\(count) Digits", style: .default) { action in
                self.pinTextField.pinCharacterCount = count
                self.pinTextField.reset()
                self.pin = ""
            }
            action.setValue(UIImage(named: "\(count)Digits"), forKey: "image")
            settings.addAction(action)
        }

        settings.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(settings, animated: true)
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
                
                vc.previousPin = pin
                vc.pinCount = pinTextField.pinCharacterCount
                vc.segueIdentifier = segueIdentifier
                vc.completion = completion
            }
        }
     }
    
}
