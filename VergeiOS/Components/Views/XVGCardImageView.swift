//
//  XVGCardImageView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 11-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class XVGCardImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.createView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.createView()
    }
    
    func createView() {
        self.layer.cornerRadius = 15
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 5
    }

}
