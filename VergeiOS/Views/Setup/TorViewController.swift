//
//  TorViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 05/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // TODO: Create a Tor setup page and move this over.
        // Set Tor enabled as default.
        ApplicationManager.default.useTor = true
        // Now start Tor.
        TorClient.shared.start {}
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
