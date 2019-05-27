//
//  LocalizableSegmentedControl.swift
//  VergeiOS
//
//  Created by Ivan Manov on 08/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class LocalizableSegmentedControl: UISegmentedControl {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for subview in self.subviews {
            for subSubview in subview.subviews {
                if subSubview.isKind(of: UILabel.self) {
                    let label = subSubview as! UILabel
                    if (label.text != nil) {
                        label.text = label.text!.localized
                    }
                }
            }
        }
    }
    
}
