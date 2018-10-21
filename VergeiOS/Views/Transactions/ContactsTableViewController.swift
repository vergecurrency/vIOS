//
//  ContactsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ContactsTableViewController: EdgedTableViewController {

    var contacts: [[Address]] = []
    var letters:[String] = []

    var addressBookManager: AddressBookManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewEdger.hideBottomShadow = true

        addressBookManager = AddressBookManager()

        let addresses = addressBookManager.all()

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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
