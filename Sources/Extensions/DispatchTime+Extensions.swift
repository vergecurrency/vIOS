//
//  DispatchTime+Extensions.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

extension DispatchTime {
    func secondsElapsed(till: DispatchTime) -> Double {
        let nanoTime = till.uptimeNanoseconds - self.uptimeNanoseconds

        return Double(nanoTime) / 1_000_000_000
    }
}
