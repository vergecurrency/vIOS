//
// Created by Swen van Zanten on 17/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit
import Charts
import DGCharts

class PriceChartView: AbstractChartView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func updateColors() {
        self.setNeedsDisplay()
    }

    var chart: LineChartView = LineChartView()

    override func layoutSubviews() {
        super.layoutSubviews()

        chart.frame = CGRect(
            x: -10,
            y: -10,
            width: bounds.width + 20,
            height: bounds.height + 10
        )
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        chart.backgroundColor = UIColor(rgb: 0x05020B)
        chart.noDataTextColor = ThemeManager.shared.secondaryDark()
        chart.dragEnabled = false
        chart.setScaleEnabled(false)
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.xAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.legend.enabled = false
        chart.chartDescription.text = ""
        chart.highlightPerTapEnabled = false
        chart.drawGridBackgroundEnabled = false
        chart.layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
        chart.layer.shadowOpacity = 0.45
        chart.layer.shadowRadius = 18
        chart.layer.shadowOffset = CGSize(width: 0, height: 0)

        if chart.superview == nil {
            addSubview(chart)
        }
    }

    func set(chartData: [ChartDataEntry]) {
        let priceSet = LineChartDataSet(entries: chartData, label: "chart.price.historyTitle".localized)
        let glowSet = LineChartDataSet(entries: chartData, label: "chart.price.historyTitle".localized)
        style(priceSet: priceSet)
        styleGlow(priceSet: glowSet)

        let data = LineChartData(dataSets: [glowSet, priceSet])
        data.setDrawValues(false)

        DispatchQueue.main.async {
            self.chart.data = data
            self.chart.animate(xAxisDuration: 1.2, easingOption: .easeInOutCirc)
            self.chart.notifyDataSetChanged()
        }
    }

    fileprivate func style(priceSet: LineChartDataSet) {
        let neonGreen = UIColor(rgb: 0x57F287)
        let neonCyan = UIColor(rgb: 0x20DFC8)
        let gradientColors = [
            neonGreen.withAlphaComponent(0.3).cgColor,
            neonCyan.withAlphaComponent(0.05).cgColor
        ]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        priceSet.mode = .cubicBezier
        priceSet.drawCirclesEnabled = false
        priceSet.drawFilledEnabled = true
        priceSet.drawHorizontalHighlightIndicatorEnabled = false
        priceSet.lineWidth = 1.5
        priceSet.highlightLineWidth = 1.0
        priceSet.fillAlpha = 1
        priceSet.highlightColor = neonCyan.withAlphaComponent(0.9)
        let fill = LinearGradientFill(gradient: gradient, angle: 90)
        priceSet.fill = fill

        priceSet.setColor(neonGreen)
    }

    fileprivate func styleGlow(priceSet: LineChartDataSet) {
        priceSet.mode = .cubicBezier
        priceSet.drawCirclesEnabled = false
        priceSet.drawFilledEnabled = false
        priceSet.drawHorizontalHighlightIndicatorEnabled = false
        priceSet.drawVerticalHighlightIndicatorEnabled = false
        priceSet.lineWidth = 7
        priceSet.highlightEnabled = false
        priceSet.setColor(UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.35))
    }
}
