//
//  TorFixViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 05/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit

class TorFixViewController: ThemeableViewController {
    var delegate: TorFixerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func restartApplication(_ sender: Any) {
        self.delegate?.restartApplication()
    }

    @IBAction func restartClient(_ sender: Any) {
        self.delegate?.restartClient()
    }
}
