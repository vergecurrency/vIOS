//
//  ChartWalletSlideView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Charts
import DGCharts
class ChartWalletSlideView: WalletSlideView, ChartViewDelegate, ChartFilterToolbarDelegate {
    @IBOutlet weak var highestPriceLabel: EFCountingLabel!
    @IBOutlet weak var averagePriceLabel: EFCountingLabel!
    @IBOutlet weak var lowestPriceLabel: EFCountingLabel!
    @IBOutlet weak var panelView: PanelView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var placeholderView: UIView!

    let priceChartView: PriceChartView = PriceChartView()
    let volumeChartView: VolumeChartView = VolumeChartView()
    let filterToolbar: ChartFilterToolbar = ChartFilterToolbar()

    var initialized = false

    var httpSession: HttpSessionProtocol!
    var filter: ChartFilterToolbar.Filter = .oneDay
    var lastChangeFilter: TimeInterval?

    var nthFilter = [
        ChartFilterToolbar.Filter.all: 3,
        ChartFilterToolbar.Filter.oneYear: 1,
        ChartFilterToolbar.Filter.threeMonths: 3,
        ChartFilterToolbar.Filter.oneMonth: 3,
        ChartFilterToolbar.Filter.oneWeek: 3,
        ChartFilterToolbar.Filter.oneDay: 1
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        super.becomeThemeable()

        self.httpSession = Application.container.resolve(HttpSessionProtocol.self)!
        self.filterToolbar.becomeThemeable()

        chartView.addSubview(volumeChartView)
        chartView.addSubview(priceChartView)
        chartView.addSubview(filterToolbar)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStats(notification:)),
            name: .didReceiveFiatRatings,
            object: nil
        )
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let filterToolbarHeight: CGFloat = 44.0
        self.filterToolbar.frame = CGRect(
            x: rect.origin.x,
            y: self.chartView.bounds.height - filterToolbarHeight,
            width: self.chartView.bounds.width,
            height: filterToolbarHeight
        )

        self.chartView.layer.cornerRadius = self.panelView.cornerRadius
        self.chartView.clipsToBounds = true
        self.layoutSubviews()

        self.initialize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let filterToolbarHeight: CGFloat = 44.0
        self.priceChartView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.chartView.bounds.width,
            height: self.chartView.bounds.height - filterToolbarHeight
        )
        self.volumeChartView.frame = CGRect(
            x: 0,
            y: self.chartView.frame.height - (self.chartView.bounds.height * 0.5),
            width: self.chartView.bounds.width,
            height: (self.chartView.bounds.height * 0.5) - filterToolbarHeight
        )

        self.priceChartView.setNeedsDisplay()
        self.volumeChartView.setNeedsDisplay()
    }

    func initialize() {
        if self.initialized {
            return
        }

        self.initialized = true

        self.loadChartData()

        self.filterToolbar.delegate = self
        self.filterToolbar.initialize()
        self.filterToolbar.select(filter: self.filter)

        let priceLabelHandler: ((CGFloat) -> String) = { value in
            NSNumber(value: Double(value)).toBlankCurrency(fractDigits: 4, floating: false)
        }

        self.highestPriceLabel.formatBlock = priceLabelHandler
        self.highestPriceLabel.method = .easeInOut
        self.averagePriceLabel.formatBlock = priceLabelHandler
        self.averagePriceLabel.method = .easeInOut
        self.lowestPriceLabel.formatBlock = priceLabelHandler
        self.lowestPriceLabel.method = .easeInOut
    }

    @objc func didReceiveStats(notification: Notification) {
        if Int(Date.timeIntervalSinceReferenceDate) > Int(lastChangeFilter ?? 0.0) {
            print("Reload chart")
            self.loadChartData()
        }
    }

    @IBAction func refreshData(sender: Any) {
        self.loadChartData()
    }

    func didSelectChartFilter(filter: ChartFilterToolbar.Filter) {
        self.filter = filter
        self.loadChartData()
    }

    func loadChartData() {
        var priceData: [ChartDataEntry] = []
        var volumeData: [BarChartDataEntry] = []
        self.priceChartView.set(chartData: priceData)
        self.volumeChartView.set(chartData: volumeData)
        self.lastChangeFilter = Date.timeIntervalSinceReferenceDate + Constants.fetchRateTimeout

        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }

        self.httpSession.dataTask(with: self.chartUrl()).then { response in
            self.placeholderView.isHidden = true
            let chartData = try response.dataToJson(type: ChartInfo.self)

            for entry in chartData.priceUsd {
                priceData.append(ChartDataEntry(x: entry[0], y: entry[1]))
            }

            for (index, entry) in chartData.volumeUsd.enumerated() {
                volumeData.append(BarChartDataEntry(x: Double(index), y: entry[1]))
            }

            self.priceChartView.set(chartData: self.nth(entries: priceData, step: self.nthFilter[self.filter]!))
            self.volumeChartView.set(chartData:
            self.nth(
                entries: volumeData,
                step: self.nthFilter[self.filter]! + 5
            ) as! [BarChartDataEntry]
            )
            self.setPriceLabels(withData: chartData.priceUsd)
            self.activityIndicator.stopAnimating()
        }.catch { _ in
            self.placeholderView.isHidden = false
        }
    }

    func setPriceLabels(withData data: [[Double]]) {
        let prices = data.map { item in
            return item[1]
        }

        let duration = 1.0
        self.highestPriceLabel.countFromCurrentValueTo(CGFloat(prices.max() ?? 0), withDuration: duration)
        self.averagePriceLabel.countFromCurrentValueTo(CGFloat(prices.average), withDuration: duration)
        self.lowestPriceLabel.countFromCurrentValueTo(CGFloat(prices.min() ?? 0), withDuration: duration)
    }

    func chartUrl() -> URL {
        let fromInterval = timeInterval(byFilter: self.filter)

        if fromInterval == nil {
            return URL(string: Constants.chartDataEndpoint)!
        }

        let now = Int(Date().timeIntervalSince1970)
        let from = Int(fromInterval!)

        let filter = "\(from)000/\(now)000/"

        return URL(string: "\(Constants.chartDataEndpoint)\(filter)")!
    }

    func timeInterval(byFilter filter: ChartFilterToolbar.Filter) -> TimeInterval? {
        switch filter {
        case .oneDay:
            return Date().yesterday.timeIntervalSince1970
        case .oneWeek:
            return Date().weekAgo.timeIntervalSince1970
        case .oneMonth:
            return Date().oneMonthAgo.timeIntervalSince1970
        case .threeMonths:
            return Date().threeMonthsAgo.timeIntervalSince1970
        case .oneYear:
            return Date().yearAgo.timeIntervalSince1970
        case .all:
            return nil
        }
    }

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
