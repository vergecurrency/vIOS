//
//  Platform.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 27-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
