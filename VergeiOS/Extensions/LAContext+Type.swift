//
//  LAContext.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 20-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import LocalAuthentication

extension LAContext {
    static func anyAvailable() -> Bool {
        return LAContext.available(type: .faceID) || LAContext.available(type: .touchID)
    }

    static func available(type: LABiometryType) -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            return (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) && context.biometryType == type)
        }
        
        return false
    }
}
