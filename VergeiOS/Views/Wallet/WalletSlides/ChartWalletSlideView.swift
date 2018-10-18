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

    @IBOutlet weak var highestPriceLabel: UILabel!
    @IBOutlet weak var averagePriceLabel: UILabel!
    @IBOutlet weak var lowestPriceLabel: UILabel!
    @IBOutlet weak var panelView: PanelView!
    @IBOutlet weak var chartView: UIView!

    let priceChartView: PriceChartView = PriceChartView()
    let volumeChartView: VolumeChartView = VolumeChartView()
    let filterToolbar: ChartFilterToolbar = ChartFilterToolbar()

    var initialized = false

    var fromInterval: TimeInterval? = Date().yesterday.timeIntervalSince1970

    var chartUrl: URL {
        let endpoint = "https://graphs2.coinmarketcap.com/currencies/"

        if fromInterval == nil {
            return URL(string: "\(endpoint)verge")!
        }

        let now = Int(Date().timeIntervalSince1970)
        let from = Int(fromInterval!)

        let filter = "\(from)000/\(now)000/"

        return URL(string: "\(endpoint)verge/\(filter)")!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        chartView.addSubview(volumeChartView)
        chartView.addSubview(priceChartView)
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

        priceChartView.frame = CGRect(
            x: rect.origin.x,
            y: 0,
            width: chartView.bounds.width,
            height: 250
        )
        volumeChartView.frame = CGRect(
            x: rect.origin.x,
            y: 150,
            width: chartView.bounds.width,
            height: 100
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
        filterToolbar.select(filter: .oneDay)
    }

    func didSelectChartFilter(filter: ChartFilterToolbar.Filter) {
        switch filter {
        case .oneDay:
            fromInterval = Date().yesterday.timeIntervalSince1970
        case .oneWeek:
            fromInterval = Date().weekAgo.timeIntervalSince1970
        case .oneMonth:
            fromInterval = Date().oneMonthAgo.timeIntervalSince1970
        case .threeMonths:
            fromInterval = Date().threeMonthsAgo.timeIntervalSince1970
        case .oneYear:
            fromInterval = Date().yearAgo.timeIntervalSince1970
        case .all:
            fromInterval = nil
        }

        loadChartData()
    }

    func loadChartData() {
        var priceData: [ChartDataEntry] = []
        var volumeData: [BarChartDataEntry] = []
        priceChartView.set(chartData: priceData)
        volumeChartView.set(chartData: volumeData)

        TorClient.shared.session.dataTask(with: chartUrl) { (data, response, error) in
            do {
                if data == nil {
                    return
                }

                let data = try JSONDecoder().decode(ChartInfo.self, from: data!)
                for entry in data.priceUsd {
                    priceData.append(ChartDataEntry(x: entry[0], y: entry[1]))
                }

                for (index, entry) in data.volumeUsd.enumerated() {
                    volumeData.append(BarChartDataEntry(x: Double(index), y: entry[1]))
                }

                DispatchQueue.main.async {
                    self.priceChartView.set(chartData: priceData)
                    self.volumeChartView.set(chartData: volumeData)
                    self.setPriceLabels(withData: data.priceUsd)
                }
            } catch {
                print(error.localizedDescription, error)
            }
        }.resume()
    }

    func setPriceLabels(withData data: [[Double]]) {
        let prices = data.map { item in
            return item[1]
        }

        highestPriceLabel.text = NSNumber(value: prices.max()!).toBlankCurrency(fractDigits: 4)
        averagePriceLabel.text = NSNumber(value: prices.average).toBlankCurrency(fractDigits: 4)
        lowestPriceLabel.text = NSNumber(value: prices.min()!).toBlankCurrency(fractDigits: 4)
    }
}
