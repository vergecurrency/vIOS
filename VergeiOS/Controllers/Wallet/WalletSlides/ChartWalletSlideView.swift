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

    var filter: ChartFilterToolbar.Filter = .oneDay
    var lastChangeFilter: TimeInterval?
    
    var nthFilter = [
        ChartFilterToolbar.Filter.all: 3,
        ChartFilterToolbar.Filter.oneYear: 1,
        ChartFilterToolbar.Filter.threeMonths: 3,
        ChartFilterToolbar.Filter.oneMonth: 3,
        ChartFilterToolbar.Filter.oneWeek: 3,
        ChartFilterToolbar.Filter.oneDay: 1,
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()

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
        filterToolbar.frame = CGRect(
            x: rect.origin.x,
            y: chartView.bounds.height - filterToolbarHeight,
            width: chartView.bounds.width,
            height: filterToolbarHeight
        )

        priceChartView.frame = CGRect(
            x: 0,
            y: 0,
            width: chartView.frame.width,
            height: chartView.frame.height - filterToolbarHeight
        )
        volumeChartView.frame = CGRect(
            x: 0,
            y: chartView.frame.height - (chartView.frame.height * 0.5),
            width: chartView.frame.width,
            height: (chartView.frame.height * 0.5) - filterToolbarHeight
        )

        chartView.layer.cornerRadius = panelView.cornerRadius
        chartView.clipsToBounds = true

        initialize()
    }

    func initialize() {
        if initialized {
            return
        }
        
        initialized = true

        loadChartData()

        filterToolbar.delegate = self
        filterToolbar.initialize()
        filterToolbar.select(filter: filter)
        
        let priceLabelHandler: ((CGFloat) -> String) = { value in
            return NSNumber(value: Double(value)).toBlankCurrency(fractDigits: 4, floating: false)
        }
        
        highestPriceLabel.formatBlock = priceLabelHandler
        highestPriceLabel.method = .easeInOut
        averagePriceLabel.formatBlock = priceLabelHandler
        averagePriceLabel.method = .easeInOut
        lowestPriceLabel.formatBlock = priceLabelHandler
        lowestPriceLabel.method = .easeInOut
    }

    @objc func didReceiveStats(notification: Notification) {
        if Int(Date.timeIntervalSinceReferenceDate) > Int(lastChangeFilter ?? 0.0) {
            print("Reload chart")
            loadChartData()
        }
    }

    func didSelectChartFilter(filter: ChartFilterToolbar.Filter) {
        self.filter = filter
        loadChartData()
    }

    func loadChartData() {
        var priceData: [ChartDataEntry] = []
        var volumeData: [BarChartDataEntry] = []
        priceChartView.set(chartData: priceData)
        volumeChartView.set(chartData: volumeData)
        lastChangeFilter = Date.timeIntervalSinceReferenceDate + Constants.fetchRateTimeout
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }

        TorClient.shared.session.dataTask(with: chartUrl()) { (data, response, error) in
            DispatchQueue.main.async {
                self.placeholderView.isHidden = data != nil
            }

            guard let data = try? JSONDecoder().decode(ChartInfo.self, from: data ?? Data()) else {
                return
            }

            for entry in data.priceUsd {
                priceData.append(ChartDataEntry(x: entry[0], y: entry[1]))
            }

            for (index, entry) in data.volumeUsd.enumerated() {
                volumeData.append(BarChartDataEntry(x: Double(index), y: entry[1]))
            }

            DispatchQueue.main.async {
                self.priceChartView.set(chartData: self.nth(entries: priceData, step: self.nthFilter[self.filter]!))
                self.volumeChartView.set(chartData: self.nth(entries: volumeData, step: self.nthFilter[self.filter]! + 5) as! [BarChartDataEntry])
                self.setPriceLabels(withData: data.priceUsd)
                self.activityIndicator.stopAnimating()
            }
        }.resume()
    }

    func setPriceLabels(withData data: [[Double]]) {
        let prices = data.map { item in
            return item[1]
        }

        let duration = 1.0
        highestPriceLabel.countFromCurrentValueTo(CGFloat(prices.max()!), withDuration: duration)
        averagePriceLabel.countFromCurrentValueTo(CGFloat(prices.average), withDuration: duration)
        lowestPriceLabel.countFromCurrentValueTo(CGFloat(prices.min()!), withDuration: duration)
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
