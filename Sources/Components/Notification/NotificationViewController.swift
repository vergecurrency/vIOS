//
// Created by Swen van Zanten on 14/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var message: UILabel!

    func setMessage(_ message: String) {
        DispatchQueue.main.async {
            self.message.text = message
        }
    }
}
