//
//  UIView+Localization.swift
//  VergeiOS
//
//  Created by Ivan Manov on 20/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    @IBInspectable var localizationId: String {
        set(value) {
            self.text = value.localized
        }
        get {
            return ""
        }
    }
    
}

extension UIButton {
    
    @IBInspectable var localizationId: String {
        set(value) {
            self.setTitle(value.localized, for: .normal)
        }
        get {
            return ""
        }
    }
    
}

extension UINavigationItem {
    
    @IBInspectable var localizationTitleId: String {
        set(value) {
            self.title = value.localized
        }
        get {
            return ""
        }
    }
    
    @IBInspectable var localizationPromptId: String {
        set(value) {
            self.prompt = value.localized
        }
        get {
            return ""
        }
    }
    
    @IBInspectable var localizationBackButtonId: String {
        set(value) {
            self.backBarButtonItem?.title = value.localized
        }
        get {
            return ""
        }
    }
    
}

extension UITextField {
    
    @IBInspectable var localizationPlaceholderId: String {
        set(value) {
            self.placeholder = value.localized
        }
        get {
            return ""
        }
    }
    
}

extension SelectorButton {
    
    @IBInspectable var localizationLabelId: String {
        set(value) {
            self.label = value.localized
        }
        get {
            return ""
        }
    }
    
}

extension UITabBarItem {
    
    @IBInspectable var localizationTitleId: String {
        set(value) {
            self.title = value.localized
        }
        get {
            return ""
        }
    }
    
}
