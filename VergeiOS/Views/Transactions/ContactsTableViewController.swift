//
//  ContactsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ContactsTableViewController: EdgedTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!

    var contacts: [[Address]] = []
    var letters:[String] = []
    var searchQuery: String = ""

    var addressBookManager: AddressBookManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewEdger.hideBottomShadow = true

        addressBookManager = AddressBookManager()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadContacts()

        tableView.reloadData()
    }

    func loadContacts() {
        contacts.removeAll()
        letters.removeAll()

        let addresses = addressBookManager.all().filter { address in
            if self.searchQuery == "" {
                return true
            }

            return address.address.lowercased().contains(self.searchQuery.lowercased())
                || address.name.lowercased().contains(self.searchQuery.lowercased())
        }

        let items = Dictionary(grouping: addresses, by: {
            return String($0.name).first?.description ?? ""
        }).sorted(by: { $0.key < $1.key })

        for item in items {
            contacts.append(item.value)
            letters.append(item.key)
        }
    }

    func sectionLetter(bySection section: Int) -> String {
        return letters[section]
    }

    func contacts(bySection section: Int) -> [Address] {
        return contacts[section]
    }

    func contact(byIndexpath indexPath: IndexPath) -> Address {
        let items = contacts(bySection: indexPath.section)

        return items[indexPath.row]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts(bySection: section).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressBookCell", for: indexPath)

        let address = contact(byIndexpath: indexPath)

        cell.textLabel?.text = address.name
        cell.detailTextLabel?.text = address.address

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLetter(bySection: section)
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

}

extension ContactsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText

        DispatchQueue.main.async {
            self.loadContacts()
            self.tableView.reloadData()
        }
    }
}
