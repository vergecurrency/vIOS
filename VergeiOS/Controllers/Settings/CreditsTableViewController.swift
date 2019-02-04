//
//  CreditsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 23-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class CreditsTableViewController: EdgedTableViewController {

    var developers = [
        [
            "name": "Swen",
            "twitter": "SwenVanZanten"
        ],
        [
            "name": "Marvin",
            "twitter": "marpme_"
        ],
        [
            "name": "Justin",
            "twitter": "justinvendetta"
        ],
        [
            "name": "Kris",
            "twitter": "ksteigerwald"
        ],
        [
            "name": "Ivan",
            "twitter": "ihellc"
        ]
    ]
    
    var designers = [
        [
            "name": "Hassan",
            "twitter": "waveon3"
        ],
        [
            "name": "Swen",
            "twitter": "SwenVanZanten"
        ],
        [
            "name": "Vadim",
            "twitter": "grevcev_vadim"
        ],
    ]
    
    var translators = [
        [
            "name": "Swen",
            "twitter": "SwenVanZanten"
        ],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return developers.count
        case 1:
            return designers.count
        case 2:
            return translators.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "creditTableViewCell", for: indexPath)

        let credit = getCredit(from: indexPath)
        
        cell.textLabel?.text = credit["name"]
        cell.detailTextLabel?.text = "@\(credit["twitter"]!)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Development"
        case 1:
            return "Design"
        case 2:
            return "Translation"
        default:
            return ""
        }
    }
    
    func getCredit(from indexPath: IndexPath) -> [String: String] {
        switch indexPath.section {
        case 0:
            return developers[indexPath.row]
        case 1:
            return designers[indexPath.row]
        case 2:
            return translators[indexPath.row]
        default:
            return [:]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let credit = getCredit(from: indexPath)
        
        loadWebsite(url: "https://twitter.com/\(credit["twitter"]!)")
    }
    
    private func loadWebsite(url: String) -> Void {
        if let path: URL = URL(string: url) {
            UIApplication.shared.open(path, options: [:])
        }
    }

}
