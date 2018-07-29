//
//  NumberKey.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class NumberKey: AbstractKey {
    var subtitle = ""
    
    init(number: Int, subtitle: String = "") {
        super.init(label: "\(number)", value: number)
        
        self.subtitle = subtitle
    }
    
    override func styleKey(_ button: KeyboardButton) {
        button.setTitle(self.label, for: .normal)
        button.titleLabel?.font = UIFont.avenir(size: 26).demiBold()

        if (self.subtitle != "") {
            let subtitle = UILabel(frame: CGRect(x: 0, y: (button.frame.size.height / 2) + 13, width: button.frame.size.width, height: 10))
            subtitle.font = UIFont.avenir(size: 10)
            subtitle.textAlignment = .center
            subtitle.textColor = UIColor.secondaryDark()
            subtitle.backgroundColor = UIColor.clear
            subtitle.text = self.subtitle
            
            button.addSubview(subtitle)
        }
    }
}
