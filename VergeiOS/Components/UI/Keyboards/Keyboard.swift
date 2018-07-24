//
//  Keyboard.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class Keyboard: PanelView {
    
    var buttons: [UIButton] = []
    var characters: [KeyboardKey] = []
    
    var delegate: KeyboardDelegate?
    
    override func createView() {
        super.createView()
        
        self.characters = self.charactersInOrder()
        
        self.drawButtons()
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
            self.addSubview(button)
            
            buttonsAdded += 1
            
            if (buttonsAdded == 3) {
                level += 1
                buttonsAdded = 0
            }
        }
    }
    
    func createButton(_ key: KeyboardKey, rect: CGRect) -> UIButton {
        let button = KeyboardButton(type: .system)
        button.frame = rect
        button.tintColor = UIColor.secondaryDark()
        button.keyboardKey = key
        button.addTarget(self, action: #selector(buttonPushed(button:)), for: .touchUpInside)
        
        if (key.isKind(of: NumberKey.self)) {
            button.setTitle(key.label, for: .normal)
            button.titleLabel?.font = UIFont.avenir(size: 26).demiBold()
        }
        
        if (key.isKind(of: ImageKey.self)) {
            button.setImage(key.image, for: .normal)
        }
        
        return button
    }
    
    @objc func buttonPushed(button: KeyboardButton) {
        if let delegate = self.delegate {
            delegate.didReceiveInput(self, input: "\(button.keyboardKey?.value ?? "")", keyboardKey: button.keyboardKey!)
        }
    }

}
