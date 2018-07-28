//
//  Platform.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 27-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
