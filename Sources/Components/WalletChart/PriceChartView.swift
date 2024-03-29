//
// Created by Swen van Zanten on 17/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit
import Charts

class PriceChartView: AbstractChartView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func updateColors() {
        self.setNeedsDisplay()
    }

    var chart: LineChartView = LineChartView()

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        chart.frame = CGRect(
            x: rect.origin.x + -10,
            y: rect.origin.y + -10,
            width: rect.size.width + 20,
            height: rect.size.height
        )

        chart.noDataTextColor = ThemeManager.shared.secondaryDark()
        chart.dragEnabled = false
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.xAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.legend.enabled = false
        chart.chartDescription?.text = ""
        chart.highlightPerTapEnabled = false

        addSubview(chart)
    }

    func set(chartData: [ChartDataEntry]) {
        let priceSet = LineChartDataSet(entries: chartData, label: "chart.price.historyTitle".localized)
        style(priceSet: priceSet)

        let data = LineChartData(dataSet: priceSet)
        data.setDrawValues(false)

        DispatchQueue.main.async {
            self.chart.data = data
            self.chart.animate(xAxisDuration: 1.2, easingOption: .easeInOutCirc)
            self.chart.notifyDataSetChanged()
        }
    }

    fileprivate func style(priceSet: LineChartDataSet) {
        let gradientColors = [
            ThemeManager.shared.priceChartColor().cgColor,
            ThemeManager.shared.primaryLight().withAlphaComponent(0.5).cgColor
        ]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        priceSet.mode = .cubicBezier
        priceSet.drawCirclesEnabled = false
        priceSet.drawFilledEnabled = true
        priceSet.drawHorizontalHighlightIndicatorEnabled = false
        priceSet.lineWidth = 1.5
        priceSet.highlightLineWidth = 1.0
        priceSet.fillAlpha = 1
        priceSet.highlightColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.9)
        priceSet.fill = Fill(linearGradient: gradient, angle: 90)
        priceSet.setColor(ThemeManager.shared.primaryLight())
    }
}
