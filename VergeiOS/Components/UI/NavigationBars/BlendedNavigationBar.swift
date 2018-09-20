//
//  BlendedNavigationBar.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 05-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class BlendedNavigationBar: UINavigationBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        DispatchQueue.main.async {
            self.setupLayout()
        }
    }
    
    func setupLayout() {
        let font = UIFont.avenir(size: 19).medium()
        
        self.shadowImage = UIImage()
        self.tintColor = UIColor.primaryLight()
        self.barTintColor = UIColor.backgroundGrey()
        self.backgroundColor = UIColor.backgroundGrey()
        self.barStyle = .default
        self.isTranslucent = false
        self.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.secondaryDark(),
            kCTFontAttributeName: font
        ] as? [NSAttributedString.Key : Any]
    }
    
}
