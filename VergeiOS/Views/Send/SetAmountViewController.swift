//
//  SetAmountViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SetAmountViewController: UIViewController, KeyboardDelegate {

    var delegate: AmountDelegate!
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountKeyboard: XvgAmountKeyboard!

    var sendTransaction: SendTransaction?
    var amountText: String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isSwipable()

        var currentAmount = delegate.currentAmount()

        amountKeyboard.delegate = self
        amountText = currentAmount.stringValue
        currencyLabel.text = delegate.currentCurrency()
        
        updateAmountLabel()
    }
    
    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey) {
        var xvg = amountText
        
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
            
            if (xvg == "0" && input != ".") {
                xvg = ""
            }
            
            xvg.append(input)
        }
        
        if let newAmount = Double(xvg) {
            sendTransaction?.setBy(currency: delegate.currentCurrency(), amount: NSNumber(value: newAmount))
        }
        
        amountText = xvg

        updateAmountLabel()
    }

    func updateAmountLabel() {
        amountLabel.text = amountText
    }
    
    @IBAction func setAmount(_ sender: Any) {
        delegate.didChangeAmount(sendTransaction!)
        
        closeViewController(self)
    }
    
    @IBAction func closeViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
