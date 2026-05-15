//
// Created by Swen van Zanten on 17/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit
import Charts
import DGCharts

class VolumeChartView: AbstractChartView {

    var chart: BarChartView = BarChartView()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.becomeThemeable()
    }

    override func updateColors() {
        self.setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        chart.frame = CGRect(
            x: -10,
            y: -10,
            width: bounds.width + 20,
            height: bounds.height + 20
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
        chart.layer.shadowColor = UIColor(rgb: 0x57F287).cgColor
        chart.layer.shadowOpacity = 0.25
        chart.layer.shadowRadius = 14
        chart.layer.shadowOffset = CGSize(width: 0, height: 0)

        if chart.superview == nil {
            addSubview(chart)
        }
    }

    func set(chartData: [BarChartDataEntry]) {
        let priceSet = BarChartDataSet(entries: chartData, label: "chart.volume.historyTitle".localized)
        style(priceSet: priceSet)

        DispatchQueue.main.async {
            self.chart.data = BarChartData(dataSet: priceSet)
            self.chart.fitBars = true
            self.chart.animate(xAxisDuration: 1.2, easingOption: .easeInOutCirc)
            self.chart.notifyDataSetChanged()
            self.chart.setNeedsDisplay()
        }
    }

    fileprivate func style(priceSet: BarChartDataSet) {
        priceSet.drawValuesEnabled = false
        priceSet.colors = [
            UIColor(rgb: 0x57F287).withAlphaComponent(0.28),
            UIColor(rgb: 0x20DFC8).withAlphaComponent(0.2),
            UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.16)
        ]
        priceSet.barBorderWidth = 2.0
        priceSet.barBorderColor = UIColor(rgb: 0x57F287).withAlphaComponent(0.22)
    }
}
