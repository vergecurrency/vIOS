//
//  TransparantNavigationBar.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 23-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TransparantNavigationBar: UINavigationBar {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let font = UIFont.avenir(size: 19).medium()
        
        self.titleTextAttributes = [kCTFontAttributeName: font] as [NSAttributedString.Key : Any]
    }

}
