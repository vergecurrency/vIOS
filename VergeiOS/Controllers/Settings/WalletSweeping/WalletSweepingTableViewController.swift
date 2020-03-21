//
//  WalletSweepingTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit
import Swinject

struct WalletSweepingItem {
    public let id: String
    public let name: String
    public let subtitle: String
}

class WalletSweepingTableViewController: UITableViewController {

    var container: Container!

    let items = [
        WalletSweepingItem(
            id: "privateKey",
            name: "settings.sweeping.cell.privateKeyLabel".localized,
            subtitle: "settings.sweeping.cell.privateKeyDecs".localized
        ),
        WalletSweepingItem(
            id: "electrum",
            name: "settings.sweeping.cell.electrumLabel".localized,
            subtitle: "settings.sweeping.cell.electrumDecs".localized
        )
        /*
        WalletSweepingItem(
            id: "android",
            name: "settings.sweeping.cell.androidLabel".localized,
            subtitle: "settings.sweeping.cell.androidDecs".localized
        )
        */
    ]

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "settings.sweeping.header.title".localized
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "settings.sweeping.footer.title".localized
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.subtitle
        cell.accessoryType = .disclosureIndicator
        cell.updateColors()
        cell.updateFonts()

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]

        switch item.id {
        case "privateKey":
            self.navigationController?.pushViewController(
                self.container.resolve(PaperWalletTableViewController.self)!,
                animated: true
            )
        case "electrum":
        self.navigationController?.pushViewController(
            self.container.resolve(ElectrumMnemonicTableViewController.self)!,
            animated: true
        )
        case "android":
            print("Not implemented")
        default:
            print("Not implemented")
        }
    }
}
