//
//  ThemeTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 05/06/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class ThemeTableViewController: EdgedTableViewController {

    var applicationRepository: ApplicationRepository!

    let themes: [String] = [
        "feather",
        "moon"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath)

        let mode = themes[indexPath.row]

        switch mode {
        case "moon":
            cell.textLabel?.text = "settings.themes.moonMode".localized
            cell.imageView?.image = UIImage(named: "Moon")
            cell.accessoryType = ThemeManager.shared.useMoonMode ? .checkmark : .none
        default:
            cell.textLabel?.text = "settings.themes.featherMode".localized
            cell.imageView?.image = UIImage(named: "Feather")
            cell.accessoryType = ThemeManager.shared.useMoonMode ? .none : .checkmark
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mode = themes[indexPath.row]

        ThemeManager.shared.switchMode(isOn: mode == "moon", appRepo: self.applicationRepository)

        (UIApplication.shared.delegate as! AppDelegate).restart(from: self)
    }
}
