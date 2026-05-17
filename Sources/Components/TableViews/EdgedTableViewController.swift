//
//  EdgedTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class EdgedTableViewController: LocalizableTableViewController {
    var scrollViewEdger: ScrollViewEdger!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollViewEdger = ScrollViewEdger(scrollView: tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollViewEdger.createShadowViews()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewEdger.updateView()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section), !title.isEmpty else {
            return nil
        }

        let container = UIView()
        container.backgroundColor = ThemeManager.shared.backgroundGrey()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title.uppercased()
        label.textColor = UIColor(rgb: 0xFF3DF2)
        label.font = UIFont.avenir(size: 13).demiBold()
        label.shadowColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.5)
        label.shadowOffset = CGSize(width: 0, height: 0)

        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])

        return container
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section), !title.isEmpty else {
            return 0
        }

        return 34
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }

        header.textLabel?.textColor = ThemeManager.shared.primaryLight()
        header.textLabel?.font = UIFont.avenir(size: 13).demiBold()
        header.textLabel?.shadowColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.45)
        header.textLabel?.shadowOffset = CGSize(width: 0, height: 0)
        header.tintColor = ThemeManager.shared.backgroundGrey()
        header.contentView.backgroundColor = ThemeManager.shared.backgroundGrey()
    }
}
