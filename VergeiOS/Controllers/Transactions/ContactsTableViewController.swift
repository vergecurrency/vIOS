//
//  ContactsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ContactsTableViewController: AbstractContactsTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigationButtons()
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

    @objc private func dismissContacts() {
        dismiss(animated: true)
    }

    @objc private func addContact() {
        performSegue(withIdentifier: "showAddContact", sender: self)
    }

    private func setupNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: makeRoundNavigationButton(label: "x", action: #selector(dismissContacts))
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: makeRoundNavigationButton(label: "+", action: #selector(addContact))
        )
    }

    private func makeRoundNavigationButton(label: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = label == "+" ? "Add contact" : "Close"
        button.addTarget(self, action: action, for: .touchUpInside)
        addVisibleLabel(label, to: button)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34)
        ])

        applyRoundRetrowaveStyle(to: button)

        DispatchQueue.main.async { [weak self, weak button] in
            guard let button = button else {
                return
            }

            self?.applyRoundRetrowaveStyle(to: button)
        }

        return button
    }

    private func addVisibleLabel(_ text: String, to button: UIButton) {
        let labelTag = 700_424
        button.subviews.filter { $0.tag == labelTag }.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.tag = labelTag
        titleLabel.text = text
        titleLabel.textColor = .white
        titleLabel.font = UIFont.avenir(size: text == "+" ? 24 : 20).demiBold()
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: text == "+" ? -1 : -2),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -4)
        ])
        button.bringSubviewToFront(titleLabel)
    }

    private func applyRoundRetrowaveStyle(to button: UIButton) {
        let gradientName = "RetrowaveContactsNavigationButtonGradient"
        button.backgroundColor = UIColor(rgb: 0x12071A)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.75).cgColor
        button.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        button.layer.shadowOpacity = 0.38
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = .zero
        button.clipsToBounds = false

        button.layer.sublayers?
            .filter { $0.name == gradientName }
            .forEach { $0.removeFromSuperlayer() }

        guard button.bounds.width > 0 && button.bounds.height > 0 else {
            return
        }

        let gradient = CAGradientLayer()
        gradient.name = gradientName
        gradient.frame = button.bounds
        gradient.cornerRadius = button.layer.cornerRadius
        gradient.colors = [
            UIColor(rgb: 0x14071F).cgColor,
            UIColor(rgb: 0x3A125C).cgColor,
            UIColor(rgb: 0x12071A).cgColor
        ]
        gradient.locations = [0.0, 0.52, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        button.layer.insertSublayer(gradient, at: 0)
        button.subviews.forEach { button.bringSubviewToFront($0) }
    }

}
