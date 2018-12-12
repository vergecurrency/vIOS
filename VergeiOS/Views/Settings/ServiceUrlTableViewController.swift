//
//  ServiceUrlTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ServiceUrlTableViewController: UITableViewController {

    @IBOutlet weak var serviceUrlTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        serviceUrlTextField.text = ApplicationManager.default.walletServiceUrl
    }

    @IBAction func setDefaultServiceUrl(_ sender: Any) {
        serviceUrlTextField.text = Config.bwsEndpoint
    }

    @IBAction func saveServiceUrl(_ sender: Any) {
        ApplicationManager.default.walletServiceUrl = serviceUrlTextField.text!

        // TODO: What's next? How are we going to do this.
    }

}
