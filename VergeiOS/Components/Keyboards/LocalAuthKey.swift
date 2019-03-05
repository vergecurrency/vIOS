//
//  LocalAuthKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 20-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import LocalAuthentication

class LocalAuthKey: ImageKey {
    
    var lastIsHidden: Bool = true
    var isHidden: Bool {
        get {
            return lastIsHidden
        }
        set {
            button?.isHidden = newValue
            lastIsHidden = newValue
        }
    }
    
    init() {
        var imageName: String?
        if LAContext.available(type: .touchID) {
            imageName = "TouchID"
        } else if LAContext.available(type: .faceID) {
            imageName = "FaceID"
        }

        var image = UIImage()
        if imageName != nil {
            image = UIImage(named: imageName!)!
        }

        super.init(image: image)
    }

    override func setButton(_ button: UIButton) {
        super.setButton(button)
        button.isHidden = isHidden
    }
}
