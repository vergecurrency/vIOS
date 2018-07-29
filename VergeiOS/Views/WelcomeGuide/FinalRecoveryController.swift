//
//  FinalRecoveryController.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 29.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class FinalRecoveryController : UIViewController {

    @IBOutlet weak var RecoveryKeyView: UITextView!
    var keys: [String]?
    
    override func viewDidLoad() {
        RecoveryKeyView.text = self.keys!.joined(separator: " ")
    }
}
