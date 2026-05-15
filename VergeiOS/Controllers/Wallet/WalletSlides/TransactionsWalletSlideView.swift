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
    private let serverStatusDot = UIView()
    private let serverStatusLabel = UILabel()
    private var didSetupServerStatusHeader = false

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
        setupServerStatusHeader()
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
        refreshServerStatus()

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
        refreshServerStatus()
        self.transactionManager.sync(limit: 10) { _ in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)

            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }

    private func setupServerStatusHeader() {
        guard !didSetupServerStatusHeader else {
            return
        }

        didSetupServerStatusHeader = true
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 48))
        header.backgroundColor = ThemeManager.shared.backgroundWhite()

        let pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = ThemeManager.shared.backgroundGrey().withAlphaComponent(0.86)
        pill.layer.cornerRadius = 16
        pill.layer.borderWidth = 1
        pill.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.38).cgColor
        pill.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        pill.layer.shadowOpacity = 0.18
        pill.layer.shadowRadius = 10
        pill.layer.shadowOffset = CGSize(width: 0, height: 0)

        serverStatusDot.translatesAutoresizingMaskIntoConstraints = false
        serverStatusDot.layer.cornerRadius = 5
        serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()

        serverStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        serverStatusLabel.font = UIFont.avenir(size: 12)
        serverStatusLabel.textColor = ThemeManager.shared.secondaryLight()
        serverStatusLabel.text = "Server: checking..."
        serverStatusLabel.adjustsFontSizeToFitWidth = true
        serverStatusLabel.minimumScaleFactor = 0.75

        header.addSubview(pill)
        pill.addSubview(serverStatusDot)
        pill.addSubview(serverStatusLabel)

        NSLayoutConstraint.activate([
            pill.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
            pill.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -12),
            pill.topAnchor.constraint(equalTo: header.topAnchor, constant: 6),
            pill.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8),

            serverStatusDot.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            serverStatusDot.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            serverStatusDot.widthAnchor.constraint(equalToConstant: 10),
            serverStatusDot.heightAnchor.constraint(equalToConstant: 10),

            serverStatusLabel.leadingAnchor.constraint(equalTo: serverStatusDot.trailingAnchor, constant: 8),
            serverStatusLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),
            serverStatusLabel.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])

        tableView.tableHeaderView = header
        refreshServerStatus()
    }

    private func refreshServerStatus() {
        guard let mnemonic = applicationRepository.mnemonic else {
            setServerStatus(name: "Server", host: nil, connected: false)
            return
        }

        if applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic) {
            setVwsStatus()
        } else {
            refreshElectrumXStatus()
        }
    }

    private func setVwsStatus() {
        guard let host = URL(string: applicationRepository.walletServiceUrl)?.host else {
            setServerStatus(name: "VWS", host: nil, connected: false)
            return
        }

        setServerStatus(name: "VWS", host: host, connected: true)
    }

    private func refreshElectrumXStatus() {
        serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
        serverStatusLabel.text = "ElectrumX: checking..."

        electrumXClient.checkConnection { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }

                if status.connected, let server = status.server {
                    self.setServerStatus(name: "ElectrumX", host: server.host, connected: true)
                } else {
                    self.setServerStatus(name: "ElectrumX", host: nil, connected: false)
                }
            }
        }
    }

    private func setServerStatus(name: String, host: String?, connected: Bool) {
        serverStatusDot.backgroundColor = connected ? ThemeManager.shared.vergeGreen() : ThemeManager.shared.vergeRed()

        if connected, let host = host {
            serverStatusLabel.text = "\(name): connected to \(host)"
        } else {
            serverStatusLabel.text = "\(name): not connected"
        }
    }

}
