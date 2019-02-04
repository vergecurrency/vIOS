//
//  CurrencyTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 02-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class CurrencyTableViewController: EdgedTableViewController {

    var selectedCurrency: String {
        return ApplicationRepository.default.currency
    }
    
    var currencies = [
        [
            "currency": "AUD",
            "name": "Australian Dollar",
        ],
        [
            "currency": "BRL",
            "name": "Brazilian Real",
        ],
        [
            "currency": "CAD",
            "name": "Canadian Dollar",
        ],
        [
            "currency": "CHF",
            "name": "Swiss Franc",
        ],
        [
            "currency": "CNY",
            "name": "Chinese Yuan",
        ],
        [
            "currency": "DKK",
            "name": "Danish krone",
        ],
        [
            "currency": "EUR",
            "name": "Euro",
        ],
        [
            "currency": "GBP",
            "name": "British Pound",
        ],
        [
            "currency": "HKD",
            "name": "Hong Kong Dollar",
        ],
        [
            "currency": "IDR",
            "name": "Indonesian Rupiah",
        ],
        [
            "currency": "RUB",
            "name": "Russian Ruble",
        ],
        [
            "currency": "SGD",
            "name": "Singapore dollar",
        ],
        [
            "currency": "THB",
            "name": "Thai Baht",
        ],
        [
            "currency": "USD",
            "name": "United States Dollar",
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.currencies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fiatCurrencyTableCell", for: indexPath)
        
        cell.accessoryType = .none //But the right way is to subclass cell and perform the same in prepare for reuse
        
        let currency = self.currencies[indexPath.row]
        
        cell.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        cell.detailTextLabel?.font = UIFont.avenir(size: 12)
        cell.textLabel?.text = currency["currency"]
        cell.detailTextLabel?.text = currency["name"]
        
        if (self.selectedCurrency == currency["currency"]) {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ApplicationRepository.default.currency = currencies[indexPath.row]["currency"]!
        
        NotificationCenter.default.post(name: .didChangeCurrency, object: currencies[indexPath.row])
        
        self.navigationController?.popViewController(animated: true)
    }

}
