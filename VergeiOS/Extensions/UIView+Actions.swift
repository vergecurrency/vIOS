//
//  UIView+Actions.swift
//  VergeiOS
//
//  Created by Ivan Manov on 2/10/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

extension UIView {
    
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "UIViewAssociatedObjectKey_tapGestureRecognizer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    public func addTapGestureRecognizer(taps: Int = 1, action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGestureRecognizer.numberOfTapsRequired = taps
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        }
    }
}
