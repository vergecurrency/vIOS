//
//  UIFont+Default.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func avenir(size: CGFloat) -> UIFont {
        return self.init(name: "Avenir Next", size: size)!
    }
    
    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
        
        traits[.weight] = weight
        
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    func bold() -> UIFont {
        return self.withWeight(.bold)
    }
    
    func demiBold() -> UIFont {
        return self.withWeight(.semibold)
    }
    
    func heavy() -> UIFont {
        return self.withWeight(.heavy)
    }
    
    func medium() -> UIFont {
        return self.withWeight(.medium)
    }
    
    func regular() -> UIFont {
        return self.withWeight(.regular)
    }
    
    func ultraLight() -> UIFont {
        return self.withWeight(.ultraLight)
    }
}
