//
// Created by Swen van Zanten on 17/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

protocol ChartFilterToolbarDelegate: class, UIToolbarDelegate {
    func didSelectChartFilter(filter: ChartFilterToolbar.Filter)
}
