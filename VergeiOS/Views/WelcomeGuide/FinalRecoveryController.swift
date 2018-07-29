//
//  FinalRecoveryController.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 29.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class FinalRecoveryController: AbstractRestoreViewController {

    @IBOutlet weak var recoveryKeyView: UILabel!

    var keys: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recoveryKeyView.text = self.keys!.joined(separator: " ")
    }
}
