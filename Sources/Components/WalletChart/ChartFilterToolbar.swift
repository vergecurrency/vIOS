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
        Filter.oneDay: "chart.filter.oneDay".localized,
        Filter.oneWeek: "chart.filter.oneWeek".localized,
        Filter.oneMonth: "chart.filter.oneMonth".localized,
        Filter.threeMonths: "chart.filter.threeMonths".localized,
        Filter.oneYear: "chart.filter.oneYear".localized,
        Filter.all: "chart.filter.all".localized
    ]

    private let buttons: [Filter] = [
        Filter.oneDay,
        Filter.oneWeek,
        Filter.oneMonth,
        Filter.oneYear,
        Filter.all
    ]

    func initialize() {
        items = []

        for index in buttons {
            let button = UIBarButtonItem(
                title: names[index],
                style: .plain,
                target: self,
                action: #selector(didSelectFilter(sender:))
            )

            button.width = 30
            button.tintColor = ThemeManager.shared.vergeGrey()

            items?.append(button)

            if buttons.last != index {
                let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                spacer.width = 3
                items?.append(spacer)
            }
        }
    }

    func select(filter: Filter) {
        deselectAllItems()

        if let delegate = delegate as? ChartFilterToolbarDelegate {
            delegate.didSelectChartFilter(filter: filter)
        }

        guard let items = items else {
            return
        }

        for item in items where item.title == names[filter] {
            item.tintColor = ThemeManager.shared.primaryLight()
        }
    }

    @objc func didSelectFilter(sender: UIBarButtonItem) {
        deselectAllItems()

        if let delegate = delegate as? ChartFilterToolbarDelegate {
            let name = sender.title
            let filter = names.first { _, value in
                return name == value
            }

            if let filter = filter?.key {
                delegate.didSelectChartFilter(filter: filter)
            }

            UISelectionFeedbackGenerator().selectionChanged()

            sender.tintColor = ThemeManager.shared.primaryLight()
        }
    }

    fileprivate func deselectAllItems() {
        guard let items = items else {
            return
        }

        for button in items {
            button.tintColor = ThemeManager.shared.vergeGrey()
        }
    }

    override func updateColors() {
        super.updateColors()

        self.select(filter: .oneDay)
    }
}
