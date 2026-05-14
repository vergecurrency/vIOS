//
//  TransactionsWalletSlideView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
//import HGPlaceholders

class TransactionsWalletSlideView: WalletSlideView, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: PlaceholderTableView!

    var transactionManager: TransactionManager!
    var addressBookManager: AddressBookRepository!
    var applicationRepository: ApplicationRepository!
    var electrumXClient: ElectrumXClient!

    var items: [Vws.TxHistory] = []
    private let electrumXStatusDot = UIView()
    private let electrumXStatusLabel = UILabel()
    private var didSetupElectrumXStatusHeader = false

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(TransactionsWalletSlideView.handleRefresh(_:)),
            for: UIControl.Event.valueChanged
        )
        refreshControl.tintColor = ThemeManager.shared.primaryLight()

        return refreshControl
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.transactionManager = Application.container.resolve(TransactionManager.self)!
        self.addressBookManager = Application.container.resolve(AddressBookRepository.self)!
        self.applicationRepository = Application.container.resolve(ApplicationRepository.self)!
        self.electrumXClient = ElectrumXClient(applicationRepository: applicationRepository)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getTransactions(notification:)),
            name: .didBroadcastTx,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getTransactions(notification:)),
            name: .didReceiveTransaction,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didSwitchWalletProfile(notification:)),
            name: .didSwitchWalletProfile,
            object: nil
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        installTableViewPlaceholder()
        setupElectrumXStatusHeader()
        getTransactions()

        tableView.layer.cornerRadius = 5.0
        tableView.clipsToBounds = true
        tableView.addSubview(refreshControl)
        tableView.backgroundColor = ThemeManager.shared.backgroundWhite()
    }

    func installTableViewPlaceholder() {
        let nib = UINib(nibName: "TransactionsPlaceholderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransactionsPlaceholderTableViewCell")
        tableView?.placeholdersProvider = PlaceholdersProvider(placeholders:
            Placeholder(cellIdentifier: "TransactionsPlaceholderTableViewCell", key: PlaceholderKey.noResultsKey)
        )
    }

    @objc func getTransactions(notification: Notification? = nil) {
        self.transactionManager.all { transactions in
            self.items = transactions

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc func didSwitchWalletProfile(notification: Notification? = nil) {
        self.items = []
        refreshElectrumXStatus()

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed(
            "TransactionTableViewCell",
            owner: self,
            options: nil
        )?.first as! TransactionTableViewCell

        let item = items[indexPath.row]

        var recipient: Contact?
        if let name = addressBookManager.name(byAddress: item.address) {
            recipient = Contact()
            recipient?.address = item.address
            recipient?.name = name
        }

        cell.setTransaction(item, address: recipient)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentContainerViewController()?.performSegue(
            withIdentifier: "TransactionTableViewController",
            sender: items[indexPath.row]
        )

        tableView.deselectRow(at: indexPath, animated: true)
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshElectrumXStatus()
        self.transactionManager.sync(limit: 10) { _ in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)

            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func setupElectrumXStatusHeader() {
        guard !didSetupElectrumXStatusHeader else {
            return
        }

        didSetupElectrumXStatusHeader = true
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 48))
        header.backgroundColor = ThemeManager.shared.backgroundWhite()

        let pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = UIColor.white
        pill.layer.cornerRadius = 16
        pill.layer.borderWidth = 1
        pill.layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor

        electrumXStatusDot.translatesAutoresizingMaskIntoConstraints = false
        electrumXStatusDot.layer.cornerRadius = 5
        electrumXStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()

        electrumXStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        electrumXStatusLabel.font = UIFont.avenir(size: 12)
        electrumXStatusLabel.textColor = ThemeManager.shared.secondaryDark()
        electrumXStatusLabel.text = "ElectrumX: checking..."
        electrumXStatusLabel.adjustsFontSizeToFitWidth = true
        electrumXStatusLabel.minimumScaleFactor = 0.75

        header.addSubview(pill)
        pill.addSubview(electrumXStatusDot)
        pill.addSubview(electrumXStatusLabel)

        NSLayoutConstraint.activate([
            pill.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
            pill.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -12),
            pill.topAnchor.constraint(equalTo: header.topAnchor, constant: 6),
            pill.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8),

            electrumXStatusDot.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            electrumXStatusDot.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            electrumXStatusDot.widthAnchor.constraint(equalToConstant: 10),
            electrumXStatusDot.heightAnchor.constraint(equalToConstant: 10),

            electrumXStatusLabel.leadingAnchor.constraint(equalTo: electrumXStatusDot.trailingAnchor, constant: 8),
            electrumXStatusLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),
            electrumXStatusLabel.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])

        tableView.tableHeaderView = header
        refreshElectrumXStatus()
    }

    private func refreshElectrumXStatus() {
        electrumXStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
        electrumXStatusLabel.text = "ElectrumX: checking..."

        electrumXClient.checkConnection { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }

                if status.connected, let server = status.server {
                    self.electrumXStatusDot.backgroundColor = ThemeManager.shared.vergeGreen()
                    self.electrumXStatusLabel.text = "ElectrumX: connected to \(server.host)"
                } else {
                    self.electrumXStatusDot.backgroundColor = ThemeManager.shared.vergeRed()
                    self.electrumXStatusLabel.text = "ElectrumX: not connected"
                }
            }
        }
    }

}
