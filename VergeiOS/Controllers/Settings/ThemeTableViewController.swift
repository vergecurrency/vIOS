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

    let themes = ThemeFactory.shared.themes

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: Table view data source
extension ThemeTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.themes.count
        } else if section == 1 {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "settings.themes.sectionHeaderTitle".localized
        } else if section == 1 {
            return "settings.themes.iconsSectionHeaderTitle".localized
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "settings.themes.sectionFooterTitle".localized
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell.init()

        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath)

            let theme = themes[indexPath.row]
            let currentTheme = ThemeManager.shared.currentTheme

            cell.textLabel?.text = theme.name
            cell.imageView?.image = theme.icon
            cell.accessoryType = theme.id == currentTheme.id ? .checkmark : .none
        }

        if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "appIconsCell", for: indexPath)

            let appIconCell = cell as! AppIconsTableViewCell

            appIconCell.didAppIconSelected = { appIcon in
                ThemeManager.shared.switchAppIcon(appIcon: appIcon)
            }
        }

        return cell
    }

}

// MARK: Table view delegate
extension ThemeTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            let theme = themes[indexPath.row]
            ThemeManager.shared.switchTheme(theme: theme)

            self.tableView.reloadData()
        }

    }

}
