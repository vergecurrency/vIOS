//
//  UIView+Theme.swift
//  VergeiOS
//
//  Created by Ivan Manov on 21.06.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit

protocol Themeable {
    func updateColors()
}

extension UIView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        //TODO subscribe to system style changed event and update colors if view supports protocol
    }
}

extension UITextField : Themeable {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateColors()
    }
    
    func updateColors() {
        guard let placeholder = self.placeholder else {
            self.attributedPlaceholder = nil
            return
        }
        
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: ThemeManager.shared.placeholderColor()
            ])
    }
}

extension UITableView : Themeable {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateColors()
    }
    
    func updateColors() {
        if (self.style == .grouped) { // Appearence for grouped style is not working
            self.backgroundColor = ThemeManager.shared.backgroundGrey()
        }
    }
}

extension UIImageView : Themeable {
    @IBInspectable var themeable: Bool {
        set(value) {
            if (value == true) {
                self.updateColors()
            }
        }
        get {
            return false
        }
    }
    
    func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
    }
}

extension RoundedButton : Themeable {
    @IBInspectable var themeable: Bool {
        set(value) {
            if (value == true) {
                self.updateColors()
            }
        }
        get {
            return false
        }
    }
    
    func updateColors() {
        self.backgroundColor = ThemeManager.shared.primaryLight()
    }
}

extension UIPageControl : Themeable {
    @IBInspectable var themeable: Bool {
        set(value) {
            if (value == true) {
                self.updateColors()
            }
        }
        get {
            return false
        }
    }
    
    func updateColors() {
        self.currentPageIndicatorTintColor = ThemeManager.shared.primaryLight()
        self.pageIndicatorTintColor = ThemeManager.shared.secondaryDark()
    }
}

extension UITableViewCell : Themeable {
    @IBInspectable var themeable: Bool {
        set(value) {
            if (value == true) {
                self.updateColors()
            }
        }
        get {
            return false
        }
    }
    
    func updateColors() {
        self.textLabel?.textColor = ThemeManager.shared.secondaryDark()
        self.detailTextLabel?.textColor = ThemeManager.shared.primaryLight()
    }
}

extension UIActivityIndicatorView : Themeable {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateColors()
    }
    
    func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
    }
}

extension UIRefreshControl : Themeable {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateColors()
    }
    
    func updateColors() {
        self.tintColor = ThemeManager.shared.primaryLight()
    }
}

extension UILabel : Themeable {
    @IBInspectable var themeable: Bool {
        set(value) {
            if (value == true) {
                self.updateColors()
            }
        }
        get {
            return false
        }
    }
    
    func updateColors() {
        self.textColor = ThemeManager.shared.primaryLight()
    }
}
