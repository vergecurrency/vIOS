//
//  SelectFiatCurrencyViewController.swift
//  VergeiOS
//
//  Created by MaXius on 03/09/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit

class SelectFiatCurrencyViewController: ThemeableViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currencyTableView: UITableView!

    var applicationRepository: ApplicationRepository!

    var selectedCurrency: String {
        return applicationRepository.currency
    }

    var currencies = [
        [
            "currency": "AUD",
            "name": "Australian Dollar"
        ],
        [
            "currency": "BRL",
            "name": "Brazilian Real"
        ],
        [
            "currency": "CAD",
            "name": "Canadian Dollar"
        ],
        [
            "currency": "CHF",
            "name": "Swiss Franc"
        ],
        [
            "currency": "CNY",
            "name": "Chinese Yuan"
        ],
        [
            "currency": "DKK",
            "name": "Danish krone"
        ],
        [
            "currency": "EUR",
            "name": "Euro"
        ],
        [
            "currency": "GBP",
            "name": "British Pound"
        ],
        [
            "currency": "HKD",
            "name": "Hong Kong Dollar"
        ],
        [
            "currency": "IDR",
            "name": "Indonesian Rupiah"
        ],
        [
            "currency": "NZD",
            "name": "New Zealand Dollar"
        ],
        [
            "currency": "RUB",
            "name": "Russian Ruble"
        ],
        [
            "currency": "SGD",
            "name": "Singapore dollar"
        ],
        [
            "currency": "THB",
            "name": "Thai Baht"
        ],
        [
            "currency": "USD",
            "name": "United States Dollar"
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        currencyTableView.delegate = self
        currencyTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeHandler(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    func numberOfSections(in currencyTableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ currencyTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.currencies.count
    }

    func tableView(_ currencyTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currencyTableView.dequeueReusableCell(
            withIdentifier: "fiatCurrencyTableCell",
            for: indexPath
        )

        cell.accessoryType = .none //But the right way is to subclass cell and perform the same in prepare for reuse

        let currency = self.currencies[indexPath.row]

        cell.updateFonts()
        cell.textLabel?.text = currency["currency"]
        cell.detailTextLabel?.text = currency["name"]

        if (self.selectedCurrency == currency["currency"]) {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    func tableView(_ currencyTableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        applicationRepository.currency = currencies[indexPath.row]["currency"]!

        NotificationCenter.default.post(name: .didChangeCurrency, object: currencies[indexPath.row])

        //NotificationCenter.default.post(name: .didChangeCurrency, object: nil)

        dismiss(animated: true, completion: nil)
    }

}