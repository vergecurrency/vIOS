//
// Created by Swen van Zanten on 17/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit
import Charts

class VolumeChartView: AbstractChartView {

    var chart: BarChartView = BarChartView()

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        chart.frame = CGRect(
            x: rect.origin.x + -10,
            y: rect.origin.y + -10,
            width: rect.size.width + 20,
            height: rect.size.height + 20
        )

        chart.noDataTextColor = UIColor.secondaryDark()
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

    func set(chartData: [BarChartDataEntry]) {
        let priceSet = BarChartDataSet(values: chartData, label: "Volume History")
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
        priceSet.colors = [UIColor.backgroundBlue()]
        priceSet.barBorderWidth = 2.0
        priceSet.barBorderColor = UIColor.backgroundBlue()
    }
}
