//
//  ContactsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ContactsTableViewController: AbstractContactsTableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupView()
        loadContacts()

        tableView.reloadData()
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            addressBookManager.remove(address: contact(byIndexpath: indexPath))

            contacts[indexPath.section].remove(at: indexPath.row)

            // Now check if the section needs deleting
            if contacts[indexPath.section].count == 0 {
                contacts.remove(at: indexPath.section)
                letters.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

            setupView()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let details = segue.destination as? ContactTableViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }

            details.contact = contact(byIndexpath: indexPath)
        }
    }

    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true)
    }

}
