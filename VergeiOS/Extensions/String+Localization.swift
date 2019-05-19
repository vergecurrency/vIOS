//
//  String+Localization.swift
//  VergeiOS
//
//  Created by Ivan Manov on 09/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

extension String {
    
    var localized : String {
        return NSLocalizedString(self, comment: "")
    }
    
}
