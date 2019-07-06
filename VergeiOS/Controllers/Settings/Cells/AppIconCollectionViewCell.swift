//
//  AppIconCollectionViewCell.swift
//  VergeiOS
//
//  Created by Ivan Manov on 06.07.2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class AppIconCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.layer.cornerRadius = 12.0
        self.imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        self.imageView.layer.borderWidth = 0.5
    }
}
