//
//  SendCardImageView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 02/06/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class SendCardImageView: CardImageView {
    override var defaultImage: UIImage {
        get {
            return UIImage(named: "SendCard")!
        }
        set {}
    }
    
    override var moonImage: UIImage {
        get {
            return UIImage(named: "SendCardMoonMode")!
        }
        set {}
    }
}
