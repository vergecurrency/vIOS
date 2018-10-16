//
// Created by Swen van Zanten on 17/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class ChartFilterToolbar: UIToolbar {

    enum Filter {
        case oneDay
        case oneWeek
        case oneMonth
        case threeMonths
        case oneYear
        case all
    }

    private let names: [Filter: String] = [
        Filter.oneDay: "1D",
        Filter.oneWeek: "1W",
        Filter.oneMonth: "1M",
        Filter.threeMonths: "3M",
        Filter.oneYear: "1Y",
        Filter.all: "All",
    ]

    private let buttons: [Filter] = [
        Filter.oneDay,
        Filter.oneWeek,
        Filter.oneMonth,
        Filter.threeMonths,
        Filter.oneYear,
        Filter.all,
    ]

    func initialize() {
        items = []

        for index in buttons {
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let button = UIBarButtonItem(
                title: names[index],
                style: .plain,
                target: self,
                action: #selector(didSelectFilter(sender:))
            )

            items?.append(button)

            if buttons.last != index {
                items?.append(flexibleSpace)
            }
        }
    }

    @objc func didSelectFilter(sender: UIBarButtonItem) {
        if let delegate = delegate as? ChartFilterToolbarDelegate {
            let name = sender.title
            let filter = names.first { _, value in
                return name == value
            }

            if let filter = filter?.key {
                delegate.didSelectChartFilter(filter: filter)
            }
        }
    }
}
