//
//  Array+Extensions.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07/03/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

extension Array {
    func sortByIndices(indices: [Int]) -> Array {
        var array: Array<Element> = []
        
        for index in indices {
            if self.indices.contains(index) {
                array.append(self[index])
            }
        }
        
        return array
    }
}
