//
//  LanguageTableViewController.swift
//  VergeiOS
//
//  Created by Ivan Manov on 19/05/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit

class LanguageTableViewController: LocalizableTableViewController {

    var applicationRepository: ApplicationRepository!

    var selectedLanguage: String? {
        return applicationRepository.language
    }

    var languages: [[String: String?]] {
        return Languages().supported
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.languages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageTableCell", for: indexPath)

        cell.accessoryType = .none //But the right way is to subclass cell and perform the same in prepare for reuse

        let language = self.languages[indexPath.row]

        cell.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        cell.detailTextLabel?.font = UIFont.avenir(size: 12)
        cell.textLabel?.text = language["localizedName"]!
        cell.detailTextLabel?.text = language["name"]!

        if (self.selectedLanguage == language["code"]) {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        applicationRepository.language = languages[indexPath.row]["code"]!

        NotificationCenter.default.post(name: .didChangeCurrency, object: languages[indexPath.row])

        (UIApplication.shared.delegate as! AppDelegate).restart()
    }

}
