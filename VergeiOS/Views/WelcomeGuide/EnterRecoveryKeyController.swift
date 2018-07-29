//
//  EnterRecoveryKeyController.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 29.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class EnterRecoveryKeyController : UIViewController {
    
    @IBOutlet weak var KeyLabel: UILabel!
    @IBOutlet weak var PreviousButton: RoundedButton!
    @IBOutlet weak var NextButton: RoundedButton!
    @IBOutlet weak var KeyTextField: UITextField!
    @IBOutlet weak var KeyProgressLabel: UILabel!
    
    private var keys : [String] = [
        String("Dog"), String("Life"), String("Head"),
        String("House"), String("Mice"), String("Lol"),
        String("Elefant"), String("Doctor"), String("Walking"),
        String("Outdoor"), String("New"), String("Buying"),
    ]
    private var index : Int = 0
    override func viewWillAppear(_ animated: Bool) {
        let navigationBar = self.navigationController?.navigationBar
        
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()
        navigationBar?.isTranslucent = true
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        self.updateView(index: self.index)
    }
    
    private func updateButton(index: Int){
        if index > 0 {
            PreviousButton.isHidden = false
        } else {
            PreviousButton.isHidden = true
        }
        
        if index < keys.count-1 {
            NextButton.isHidden = false
        } else {
            NextButton.setTitle("Restore", for: .normal)
        }
    }
    
    private func createLabelText() -> String {
        return "Enter Keys:"
    }
    
    private func createProgressText(index: Int) -> String {
        return "\(index+1) / \(self.keys.count)"
    }
    
    private func createPlaceholderText(index: Int) -> String {
        return "Key #\(index+1) (e.g. Cat)"
    }
    
    private func updateView(index: Int) {
        self.KeyLabel.text = self.createLabelText()
        self.KeyTextField.text = self.keys[self.index]
        self.KeyTextField.placeholder = self.createPlaceholderText(index: self.index)
        self.KeyProgressLabel.text = self.createProgressText(index: self.index)
        self.updateButton(index: self.index)
    }
    
    private func addKeyToList(text: String?) -> Bool {
        if text == nil || text!.count == 0{
            return false
        }
        
        self.keys[self.index] = text!
        return true
    }
    
    @IBAction func previousClick(_ sender: RoundedButton) {
        self.index -= 1
        self.updateView(index: self.index)
    }
    
    @IBAction func nextClick(_ sender: RoundedButton) {
        let isAdded: Bool = self.addKeyToList(text: self.KeyTextField.text)
        
        if self.index < self.keys.count-1 {
            if isAdded {
                self.index += 1
                self.updateView(index: self.index)
            } else {
                self.KeyTextField.shake()
                return
            }
        }else {
            self.performSegue(withIdentifier: "showFinalRecovery", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let finalRecoverController = segue.destination as? FinalRecoveryController
        finalRecoverController?.keys = self.keys as Array
    }
}
