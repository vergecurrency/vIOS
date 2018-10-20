//
// Created by Swen van Zanten on 20/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import Charts

class AbstractChartView: UIView {

    func nth(entries: [ChartDataEntry], step: Int) -> [ChartDataEntry] {
        var position = 0

        let values: [Double] = entries.map { item in
            return item.y
        }

        let highest = values.max()
        let lowest = values.min()

        return entries.filter { args in
            if args.y == highest || args.y == lowest {
                return true
            }

            position = 1 + position
            return position % step == 0
        }
    }

}
