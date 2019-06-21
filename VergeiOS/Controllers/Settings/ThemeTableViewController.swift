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

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.themes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "settings.themes.sectionHeaderTitle".localized
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "settings.themes.sectionFooterTitle".localized
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath)

        let theme = themes[indexPath.row]
        let currentTheme = ThemeManager.shared.currentTheme
        
        cell.textLabel?.text = theme.name
        cell.imageView?.image = theme.icon
        cell.accessoryType = theme.id == currentTheme.id ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = themes[indexPath.row]
        
        ThemeManager.shared.switchTheme(theme: theme)
    }
}
