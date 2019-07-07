//
//  SummaryWalletSlideView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class SummaryWalletSlideView: WalletSlideView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderView: UIView!

    var applicationRepository: ApplicationRepository!
    var fiatRateTicker: FiatRateTicker!
    var items: [String] = [
        "price",
        "marketCap",
        "dayChangePercentage",
        "dayHigh",
        "dayLow",
        "dayChangeValue",
        "dayTotalvolume",
        "dayTotalvolumePair",
    ]

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.applicationRepository = Application.container.resolve(ApplicationRepository.self)!
        self.fiatRateTicker = Application.container.resolve(FiatRateTicker.self)!

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStats(notification:)),
            name: .didReceiveFiatRatings,
            object: nil
        )
    }
    
    override func updateColors() {
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Remove the last line.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.layer.cornerRadius = 5.0
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = ThemeManager.shared.backgroundWhite()
    }
    
    private var fiatRateInfo: FiatRate? {
        return self.fiatRateTicker.rateInfo
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "summaryCell")
        cell.backgroundColor = .clear
        
        let item = items[indexPath.row]
        
        cell.textLabel?.font = UIFont.avenir(size: 14).demiBold()
        cell.detailTextLabel?.font = UIFont.avenir(size: 15).demiBold()
        
        cell.textLabel?.textColor = ThemeManager.shared.secondaryDark()
        cell.detailTextLabel?.textColor = ThemeManager.shared.secondaryDark()

        return setupCell(cell, item: item)
    }
    
    func setupCell(_ cell: UITableViewCell, item: String) -> UITableViewCell {
        
        if let info = fiatRateInfo {
            switch item {
            case "price":
                cell.textLabel?.text = "XVG/\(self.applicationRepository.currency)"
                cell.detailTextLabel?.text = NSNumber(value: info.price).toPairCurrency(fractDigits: 6)
                break
            case "marketCap":
                cell.textLabel?.text = "wallet.slides.summary.marketCap".localized
                cell.detailTextLabel?.text = NSNumber(value: info.mktcap).toPairCurrency(fractDigits: 0)
                break
            case "dayHigh":
                cell.textLabel?.text = "wallet.slides.summary.24hHigh".localized
                cell.detailTextLabel?.text = NSNumber(value: info.high24Hour).toPairCurrency(fractDigits: 6)
                cell.detailTextLabel?.textColor = ThemeManager.shared.vergeGreen()
                break
            case "dayLow":
                cell.textLabel?.text = "wallet.slides.summary.24hLow".localized
                cell.detailTextLabel?.text = NSNumber(value: info.low24Hour).toPairCurrency(fractDigits: 6)
                cell.detailTextLabel?.textColor = ThemeManager.shared.vergeRed()
                break
            case "dayChangePercentage":
                cell.textLabel?.text = "wallet.slides.summary.24hChange".localized
                cell.detailTextLabel?.text = "\(String(format: "%.2f", info.changepct24Hour))%"
                stylePercentageLabel(cell.detailTextLabel!, value: info.change24Hour)
                break
            case "dayChangeValue":
                cell.textLabel?.text = "wallet.slides.summary.24hChange".localized
                cell.detailTextLabel?.text = NSNumber(value: info.change24Hour).toPairCurrency(fractDigits: 6)
                break
            case "dayTotalvolume":
                cell.textLabel?.text = "wallet.slides.summary.24hVolume".localized
                cell.detailTextLabel?.text = NSNumber(value: info.totalvolume24H).toXvgCurrency(fractDigits: 0)
                break
            case "dayTotalvolumePair":
                cell.textLabel?.text = "wallet.slides.summary.24hVolume".localized
                cell.detailTextLabel?.text = NSNumber(value: info.totalvolume24Hto).toPairCurrency(fractDigits: 0)
                break
            default:
                cell.textLabel?.text = "Not"
                cell.detailTextLabel?.text = "Implemented"
            }
        }
        
        return cell
    }

    func stylePercentageLabel(_ label: UILabel, value: Double) {
        label.textColor = value > 0.0 ? ThemeManager.shared.vergeGreen() : ThemeManager.shared.vergeRed()
    }

    @objc func didReceiveStats(notification: Notification? = nil) {
        DispatchQueue.main.async {
            self.placeholderView.isHidden = self.fiatRateInfo != nil
            if self.fiatRateInfo != nil {
                self.tableView.reloadData()
            }
        }
    }
    
}
