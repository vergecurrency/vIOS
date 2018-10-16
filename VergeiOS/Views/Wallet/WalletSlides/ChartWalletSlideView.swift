//
//  ChartWalletSlideView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Charts

class ChartWalletSlideView: WalletSlideView, ChartViewDelegate, ChartFilterToolbarDelegate {

    @IBOutlet weak var panelView: PanelView!
    @IBOutlet weak var chartView: UIView!

    let filterToolbar: ChartFilterToolbar = ChartFilterToolbar()

    override func awakeFromNib() {
        super.awakeFromNib()

        filterToolbar.delegate = self

        chartView.addSubview(filterToolbar)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let filterToolbarHeight: CGFloat = 44.0
        filterToolbar.frame = CGRect(
            x: rect.origin.x,
            y: chartView.bounds.height - filterToolbarHeight,
            width: chartView.bounds.width,
            height: filterToolbarHeight
        )
        filterToolbar.initialize()
    }

    func didSelectChartFilter(filter: ChartFilterToolbar.Filter) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()

        print(filter)
    }
}
