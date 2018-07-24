//
//  PanelView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class PanelView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.createView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.createView()
    }
    
    func createView() {
        self.backgroundColor = .white
        
        self.layer.cornerRadius = 5
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 15
    }

}
