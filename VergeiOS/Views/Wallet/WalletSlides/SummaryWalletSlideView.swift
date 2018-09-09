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
    
    var items: [String] = [
        "price",
        "marketCap",
        "rank",
        "dayChangePercentage",
        "dayHigh",
        "dayLow",
        "dayChangeValue",
        "dayTotalvolume",
        "dayTotalvolumePair",
    ]

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStats(notification:)),
            name: .didReceiveStats,
            object: nil
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Remove the last line.
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.layer.cornerRadius = 5.0
        tableView.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "summaryCell")

        let item = items[indexPath.row]
        
        cell.textLabel?.font = UIFont.avenir(size: 14).demiBold()
        cell.detailTextLabel?.font = UIFont.avenir(size: 15).demiBold()
        
        cell.textLabel?.textColor = UIColor.secondaryDark()
        cell.detailTextLabel?.textColor = UIColor.secondaryDark()

        return setupCell(cell, item: item)
    }
    
    func setupCell(_ cell: UITableViewCell, item: String) -> UITableViewCell {
        
        if let info = PriceTicker.shared.xvgInfo {
            switch item {
            case "price":
                cell.textLabel?.text = "XVG/USD"
                cell.detailTextLabel?.text = info.display.price
                break
            case "marketCap":
                cell.textLabel?.text = "Market Cap"
                cell.detailTextLabel?.text = info.display.mktcap
                break
            case "dayHigh":
                cell.textLabel?.text = "24h High"
                cell.detailTextLabel?.text = info.display.high24Hour
                cell.detailTextLabel?.textColor = .vergeGreen()
                break
            case "dayLow":
                cell.textLabel?.text = "24h Low"
                cell.detailTextLabel?.text = info.display.low24Hour
                cell.detailTextLabel?.textColor = .vergeRed()
                break
            case "rank":
                cell.textLabel?.text = "CMC Rank"
                cell.detailTextLabel?.text = "-"
                break
            case "dayChangePercentage":
                cell.textLabel?.text = "24h Change"
                cell.detailTextLabel?.text = "\(info.display.changepct24Hour)%"
                stylePercentageLabel(cell.detailTextLabel!, value: info.raw.change24Hour)
                break
            case "dayChangeValue":
                cell.textLabel?.text = "24h Change"
                cell.detailTextLabel?.text = info.display.change24Hour
                break
            case "dayTotalvolume":
                cell.textLabel?.text = "24h Volume"
                cell.detailTextLabel?.text = info.display.totalvolume24H
                break
            case "dayTotalvolumePair":
                cell.textLabel?.text = "24h Volume"
                cell.detailTextLabel?.text = info.display.totalvolume24Hto
                break
            default:
                cell.textLabel?.text = "Not"
                cell.detailTextLabel?.text = "Implemented"
            }
        }
        
        return cell
    }

    func stylePercentageLabel(_ label: UILabel, value: Double) {
        label.textColor = value > 0.0 ? UIColor.vergeGreen() : UIColor.vergeRed()
    }

    @objc func didReceiveStats(notification: Notification? = nil) {
        tableView.reloadData()
    }
    
}
