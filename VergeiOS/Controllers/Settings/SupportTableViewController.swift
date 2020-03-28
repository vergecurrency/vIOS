//
//  SupportTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit

private struct SupportLink {
    public let name: String
    public let link: String
}

class SupportTableViewController: EdgedTableViewController {

    private let items: [SupportLink] = [
        SupportLink(
            name: "Support Page",
            link: "https://vergesupport.altervista.org/knowledge-base/install-and-configure-your-ios-wallet/"
        ),
        SupportLink(name: "Discord", link: "https://discord.gg/vergecurrency"),
        SupportLink(name: "Facebook", link: "https://www.facebook.com/VERGEcurrency/"),
        SupportLink(name: "Reddit", link: "https://www.reddit.com/r/vergecurrency/"),
        SupportLink(name: "Telegram", link: "https://t.me/XVGwalletsupport"),
        SupportLink(name: "Twitter", link: "https://www.twitter.com/vergecurrency"),
        SupportLink(name: "GitHub", link: "https://github.com/vergecurrency/vIOS")
    ]

    static func createFromStoryBoard() -> SupportTableViewController {
        guard let controller = UIStoryboard(name: "Settings", bundle: nil)
            .instantiateViewController(
                withIdentifier: "SupportTableViewController"
            ) as? SupportTableViewController else {
            fatalError("Can't create SupportTableViewController from the StoryBoard")
        }

        return controller
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "settings.other.cell.supportLabel".localized
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.link
        cell.accessoryType = .disclosureIndicator
        cell.updateColors()
        cell.updateFonts()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]

        if let path: URL = URL(string: item.link) {
            UIApplication.shared.open(path, options: [:])
        }
    }

}
