//
//  DateUtils.swift
//  Awoo
//
//  Created by Swen van Zanten on 21-04-18.
//  Copyright © 2018 Swen van Zanten. All rights reserved.
//

import Foundation

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var weekAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)!
    }
    
    var oneMonthAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
    
    var threeMonthsAgo: Date {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)!
    }
    
    var yearAgo: Date {
        return Calendar.current.date(byAdding: .year, value: -1, to: self)!
    }

    var string: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short

        return df.string(from: self)
    }
}
