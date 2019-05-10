//
//  LocalizableTableViewController.swift
//  VergeiOS
//
//  Created by Ivan Manov on 08/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class LocalizableTableViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = super.tableView(tableView, titleForHeaderInSection: section) ?? nil
        
        return (title != nil) ? NSLocalizedString(title!, comment: "") : nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let title = super.tableView(tableView, titleForFooterInSection: section) ?? nil
        
        return (title != nil) ? NSLocalizedString(title!, comment: "") : nil
    }
}
