//
//  UIView+Theme.swift
//  VergeiOS
//
//  Created by Ivan Manov on 21.06.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setPlaceholderColor()
    }
    
    func setPlaceholderColor() {
        guard let placeholder = self.placeholder else {
            self.attributedPlaceholder = nil
            return
        }
        
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: ThemeManager.shared.placeholderColor()
            ])
    }
}

extension UITableView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateBackgroundColor()
    }
    
    func updateBackgroundColor() {
        self.backgroundColor = ThemeManager.shared.backgroundGrey()
    }
}
