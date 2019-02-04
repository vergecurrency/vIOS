//
// Created by Swen van Zanten on 25/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import UIKit

class AbstractContactsTableViewController: UITableViewController {

    var contacts: [[Contact]] = []
    var letters:[String] = []
    let addressBookManager: AddressBookRepository = AddressBookRepository()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if searchController.isActive {
            TorStatusIndicator.shared.hide()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        TorStatusIndicator.shared.show()
    }

    func setupView() {
        if addressBookManager.isEmpty() {
            if let placeholder = Bundle.main.loadNibNamed(
                "NoContactsPlaceholderView",
                owner: self,
                options: nil
            )?.first as? NoContactsPlaceholderView {
                placeholder.frame = tableView.frame
                tableView.backgroundView = placeholder
                tableView.backgroundView?.backgroundColor = .backgroundGrey()
                tableView.tableFooterView = UIView()
                navigationItem.searchController = nil
            }
            return
        }

        tableView.backgroundView = nil
        tableView.backgroundView?.backgroundColor = .backgroundGrey()
        tableView.tableFooterView = nil

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        edgesForExtendedLayout = UIRectEdge.all
        extendedLayoutIncludesOpaqueBars = true

        // Setup the Scope Bar
        searchController.searchBar.delegate = self
        searchController.delegate = self
    }

    func loadContacts(_ searchText: String = "") {
        contacts.removeAll()
        letters.removeAll()

        let addresses = addressBookManager.all().filter { address in
            if searchText == "" {
                return true
            }

            return address.address.lowercased().contains(searchText.lowercased())
                || address.name.lowercased().contains(searchText.lowercased())
        }

        let items = Dictionary(grouping: addresses, by: {
            return String($0.name).first?.description ?? ""
        }).sorted(by: { $0.key < $1.key })

        for item in items {
            letters.append(item.key)
            contacts.append(item.value.sorted { thule, thule2 in
                return thule.name < thule2.name
            })
        }
    }

    func sectionLetter(bySection section: Int) -> String {
        return letters[section]
    }

    func contacts(bySection section: Int) -> [Contact] {
        return contacts[section]
    }

    func contact(byIndexpath indexPath: IndexPath) -> Contact {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressBookCell")!

        let address = contact(byIndexpath: indexPath)

        cell.textLabel?.text = address.name
        cell.detailTextLabel?.text = address.address

        return cell
    }

}

extension AbstractContactsTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        loadContacts(searchBar.text!)
        tableView.reloadData()
    }
}

extension AbstractContactsTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        loadContacts(searchController.searchBar.text!)
        tableView.reloadData()
    }

    public func willPresentSearchController(_ searchController: UISearchController) {
        TorStatusIndicator.shared.hide()
    }

    public func willDismissSearchController(_ searchController: UISearchController) {
        TorStatusIndicator.shared.show()
    }
}
