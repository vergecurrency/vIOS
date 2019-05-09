//
//  LocalAuthTableViewCell.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 20-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import LocalAuthentication

class LocalAuthTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if LAContext.available(type: .touchID) {
            textLabel?.text = "settings.localAuth.useTouchId".localized
            imageView?.image = UIImage(named: "TouchID")
        }
    }

}
