//
// Created by Swen van Zanten on 25/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class AbstractContactsTableViewController: EdgedTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!

    var contacts: [[Address]] = []
    var letters:[String] = []
    var searchQuery: String = ""
    let addressBookManager: AddressBookManager = AddressBookManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewEdger.hideBottomShadow = true
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLetter(bySection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressBookCell", for: indexPath)

        let address = contact(byIndexpath: indexPath)

        cell.textLabel?.text = address.name
        cell.detailTextLabel?.text = address.address

        return cell
    }

}

extension AbstractContactsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText

        DispatchQueue.main.async {
            self.loadContacts()
            self.tableView.reloadData()
        }
    }
}
