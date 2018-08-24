//
//  PanelView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

@IBDesignable class PanelView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 5.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.createView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.createView()
    }
    
    func createView() {
        self.layer.cornerRadius = cornerRadius
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 15
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = cornerRadius

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 15
    }
}
