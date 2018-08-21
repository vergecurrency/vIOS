//
//  Keyboard.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class Keyboard: UIView {

    var shadowLayer: CAShapeLayer!
    var containerView: UIView?
    var buttons: [UIButton] = []
    var characters: [KeyboardKey] = []
    
    var delegate: KeyboardDelegate?

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        backgroundColor = .clear

        for view in subviews {
            view.removeFromSuperview()
        }

        containerView = UIView(frame: rect)
        containerView?.layer.cornerRadius = 5
        containerView?.clipsToBounds = true
        addSubview(containerView!)

        characters = charactersInOrder()
        drawButtons()

        layer.cornerRadius = 5

        shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 5).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor

        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize.zero
        shadowLayer.shadowOpacity = 0.15
        shadowLayer.shadowRadius = 15

        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func charactersInOrder() -> [KeyboardKey] {
        return []
    }
    
    func drawButtons() {
        var buttonsAdded = 0
        var level = 0
        
        for (index, key) in self.characters.enumerated() {
            let buttonWidth = self.frame.width / 3
            let buttonHeight = self.frame.height / 4
            let xPosition = (CGFloat(index) - (CGFloat(level) * 3)) * buttonWidth
            let yPosition = CGFloat(level) * buttonHeight
            let buttonRect = CGRect(x: xPosition, y: yPosition, width: buttonWidth, height: buttonHeight)
            let button = self.createButton(key, rect: buttonRect)
            
            self.buttons.append(button)
            self.containerView?.addSubview(button)
            
            buttonsAdded += 1
            
            if (buttonsAdded == 3) {
                level += 1
                buttonsAdded = 0
            }
        }
    }
    
    func createButton(_ key: KeyboardKey, rect: CGRect) -> UIButton {
        let button = KeyboardButton(type: .custom)
        button.frame = rect
        button.keyboardKey = key
        button.tintColor = UIColor.secondaryDark()
        button.setTitleColor(UIColor.secondaryDark(), for: .normal)
        button.setTitleColor(UIColor.primaryDark(), for: .highlighted)
        
        if (!key.isKind(of: EmptyKey.self)) {
            button.addTarget(self, action: #selector(buttonPushed(button:)), for: .touchUpInside)
            button.setBackgroundColor(color: UIColor.backgroundBlue(), forState: UIControlState.highlighted)
        }
        
        key.styleKey(button)
        key.setButton(button)
        
        return button
    }
    
    @objc func buttonPushed(button: KeyboardButton) {
        if let delegate = self.delegate {
            delegate.didReceiveInput(self, input: "\(button.keyboardKey?.getValue() ?? "")", keyboardKey: button.keyboardKey!)
        }
    }

}
