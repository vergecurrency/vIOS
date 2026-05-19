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
    var walletClient: WalletClientProtocol!
    var torClient: TorClient!

    var items: [Vws.TxHistory] = []
    private let serverStatusDot = UIView()
    private let serverStatusLabel = UILabel()
    private let serverStatusContainer = UIView()
    private var didSetupServerStatusHeader = false
    private var pendingAmountRefreshWorkItem: DispatchWorkItem?
    private var periodicRefreshTimer: Timer?
    private var didLoadInitialTransactions = false
    private var lastServerStatusRefreshAt: Date?
    private let serverStatusRefreshInterval: TimeInterval = 30

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
        self.walletClient = Application.container.resolve(WalletClientProtocol.self)!
        self.torClient = Application.container.resolve(TorClient.self)!
        self.electrumXClient = ElectrumXClient(
            applicationRepository: applicationRepository,
            httpSession: Application.container.resolve(HttpSessionProtocol.self),
            hiddenClient: Application.container.resolve(TorClient.self)
        )
    }

    deinit {
        periodicRefreshTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeWalletAmount(notification:)),
            name: .didChangeWalletAmount,
            object: nil
        )

        [
            Notification.Name.didStartTorThread: #selector(didStartTorThread(notification:)),
            Notification.Name.didConnectTorController: #selector(didConnectTorController(notification:)),
            Notification.Name.didUpdateTorBootstrapProgress: #selector(didUpdateTorBootstrapProgress(notification:)),
            Notification.Name.didEstablishTorConnection: #selector(didEstablishTorConnection(notification:)),
            Notification.Name.didFinishTorStart: #selector(didFinishTorStart(notification:)),
            Notification.Name.didResignTorConnection: #selector(didResignTorConnection(notification:)),
            Notification.Name.didTurnOffTor: #selector(didTurnOffTor(notification:)),
            Notification.Name.errorDuringTorConnection: #selector(errorDuringTorConnection(notification:))
        ].forEach { name, selector in
            NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        installTableViewPlaceholder()
        setupServerStatusHeader()
        if !didLoadInitialTransactions {
            didLoadInitialTransactions = true
            getTransactions()
        }

        tableView.layer.cornerRadius = 10.0
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.22).cgColor
        tableView.clipsToBounds = true
        tableView.addSubview(refreshControl)
        tableView.backgroundColor = ThemeManager.shared.backgroundWhite()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil {
            stopPeriodicRefresh()
        } else {
            startPeriodicRefresh()
        }
    }

    func installTableViewPlaceholder() {
        let nib = UINib(nibName: "TransactionsPlaceholderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransactionsPlaceholderTableViewCell")
        tableView?.placeholdersProvider = PlaceholdersProvider(placeholders:
            Placeholder(cellIdentifier: "TransactionsPlaceholderTableViewCell", key: PlaceholderKey.noResultsKey)
        )
    }

    @objc func getTransactions(notification: Notification? = nil) {
        let shouldForceSync = notification?.name == .didBroadcastTx
        if shouldForceSync || transactionManager.needsSync(maxAge: 25) {
            setSyncingStatus()
        }

        let completion: ([Vws.TxHistory]) -> Void = { transactions in
            self.items = transactions

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshServerStatus()
            }
        }

        if shouldForceSync {
            self.transactionManager.sync(limit: 10, completion: completion)
        } else {
            self.transactionManager.syncIfStale(maxAge: 25, limit: 10, completion: completion)
        }
    }

    @objc func didSwitchWalletProfile(notification: Notification? = nil) {
        pendingAmountRefreshWorkItem?.cancel()
        pendingAmountRefreshWorkItem = nil
        self.items = []
        refreshServerStatus()

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @objc func didChangeWalletAmount(notification: Notification? = nil) {
        guard isElectrumXWallet else {
            return
        }

        scheduleElectrumXTransactionRefresh()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
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
        setSyncingStatus()
        self.transactionManager.sync(limit: 10) { _ in
            NotificationCenter.default.post(name: .didReceiveTransaction, object: nil)

            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.refreshServerStatus()
            }
        }
    }

    private func startPeriodicRefresh() {
        guard periodicRefreshTimer == nil else {
            return
        }

        periodicRefreshTimer = Timer.scheduledTimer(
            withTimeInterval: 20,
            repeats: true
        ) { [weak self] _ in
            self?.refreshRecentTransactionsFromTimer()
        }
    }

    private func stopPeriodicRefresh() {
        periodicRefreshTimer?.invalidate()
        periodicRefreshTimer = nil
    }

    private func refreshRecentTransactionsFromTimer() {
        guard window != nil,
              applicationRepository.setup,
              !isWaitingForTor() else {
            return
        }

        let profileId = applicationRepository.activeWalletProfileId
        if transactionManager.needsSync(maxAge: 25) {
            setSyncingStatus()
        }

        transactionManager.syncIfStale(maxAge: 25, limit: 10) { [weak self] transactions in
            guard let self = self,
                  self.applicationRepository.activeWalletProfileId == profileId else {
                return
            }

            DispatchQueue.main.async {
                self.items = transactions
                self.tableView.reloadData()
                self.refreshServerStatus()
            }
        }
    }

    private var isElectrumXWallet: Bool {
        guard let mnemonic = applicationRepository.mnemonic else {
            return false
        }

        return !applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic)
    }

    private func scheduleElectrumXTransactionRefresh() {
        pendingAmountRefreshWorkItem?.cancel()

        let profileId = applicationRepository.activeWalletProfileId
        let workItem = DispatchWorkItem { [weak self] in
            self?.refreshElectrumXTransactions(profileId: profileId, retryAfter: 2.0)
        }

        pendingAmountRefreshWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }

    private func refreshElectrumXTransactions(profileId: String, retryAfter: TimeInterval?) {
        guard applicationRepository.activeWalletProfileId == profileId,
              isElectrumXWallet else {
            return
        }

        if retryAfter != nil && transactionManager.needsSync(maxAge: 2) {
            setSyncingStatus()
        }

        transactionManager.sync(limit: 10) { [weak self] transactions in
            guard let self = self,
                  self.applicationRepository.activeWalletProfileId == profileId else {
                return
            }

            DispatchQueue.main.async {
                self.items = transactions
                self.tableView.reloadData()
                self.refreshServerStatus()
            }

            guard let retryAfter = retryAfter else {
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + retryAfter) { [weak self] in
                self?.refreshElectrumXTransactions(profileId: profileId, retryAfter: nil)
            }
        }
    }

    private func setupServerStatusHeader() {
        guard !didSetupServerStatusHeader else {
            return
        }

        didSetupServerStatusHeader = true
        guard let panel = tableView.superview, let rootView = panel.superview else {
            return
        }

        movePanelBelowServerStatus(panel)

        serverStatusContainer.translatesAutoresizingMaskIntoConstraints = false
        serverStatusContainer.backgroundColor = .clear

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
        serverStatusLabel.text = "Status: connecting..."
        serverStatusLabel.adjustsFontSizeToFitWidth = true
        serverStatusLabel.minimumScaleFactor = 0.75

        serverStatusContainer.addSubview(pill)
        pill.addSubview(serverStatusDot)
        pill.addSubview(serverStatusLabel)
        rootView.addSubview(serverStatusContainer)

        NSLayoutConstraint.activate([
            serverStatusContainer.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            serverStatusContainer.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            serverStatusContainer.bottomAnchor.constraint(equalTo: panel.topAnchor, constant: -8),
            serverStatusContainer.heightAnchor.constraint(equalToConstant: 40),

            pill.leadingAnchor.constraint(equalTo: serverStatusContainer.leadingAnchor),
            pill.trailingAnchor.constraint(equalTo: serverStatusContainer.trailingAnchor),
            pill.topAnchor.constraint(equalTo: serverStatusContainer.topAnchor),
            pill.bottomAnchor.constraint(equalTo: serverStatusContainer.bottomAnchor),

            serverStatusDot.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
            serverStatusDot.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            serverStatusDot.widthAnchor.constraint(equalToConstant: 10),
            serverStatusDot.heightAnchor.constraint(equalToConstant: 10),

            serverStatusLabel.leadingAnchor.constraint(equalTo: serverStatusDot.trailingAnchor, constant: 8),
            serverStatusLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),
            serverStatusLabel.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])

        tableView.tableHeaderView = nil
        refreshServerStatus(force: true)
    }

    private func movePanelBelowServerStatus(_ panel: UIView) {
        guard let rootView = panel.superview else {
            return
        }

        for constraint in rootView.constraints {
            let firstMatches = constraint.firstItem as? UIView === panel && constraint.firstAttribute == .top
            let secondMatches = constraint.secondItem as? UIView === panel && constraint.secondAttribute == .top

            if firstMatches || secondMatches {
                constraint.constant = 56
            }
        }
    }

    private func refreshServerStatus(force: Bool = false) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.refreshServerStatus(force: force)
            }
            return
        }

        guard !isWaitingForTor() else {
            setTorPendingStatus()
            return
        }

        guard let mnemonic = applicationRepository.mnemonic else {
            setServerStatus(name: "Server", host: nil, state: "connecting")
            return
        }

        if applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic) {
            setVwsStatus(force: force)
        } else {
            refreshElectrumXStatus(force: force)
        }
    }

    private func shouldProbeServerStatus(force: Bool) -> Bool {
        guard !force else {
            lastServerStatusRefreshAt = Date()
            return true
        }

        if let lastServerStatusRefreshAt = lastServerStatusRefreshAt,
           Date().timeIntervalSince(lastServerStatusRefreshAt) < serverStatusRefreshInterval {
            return false
        }

        lastServerStatusRefreshAt = Date()
        return true
    }

    private func setVwsStatus(force: Bool = false) {
        guard let host = URL(string: applicationRepository.walletServiceUrl)?.host else {
            setServerStatus(name: "VWS", host: nil, state: "connecting")
            return
        }

        guard shouldProbeServerStatus(force: force) else {
            return
        }

        setServerStatus(name: "VWS", host: host, state: "connecting")
        walletClient.openWallet { [weak self] _, errorResponse, error in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }

                if error != nil || errorResponse != nil {
                    self.setServerStatus(name: "VWS", host: host, state: "error")
                } else {
                    self.setServerStatus(name: "VWS", host: host, state: "connected")
                }
            }
        }
    }

    private func refreshElectrumXStatus(force: Bool = false) {
        guard shouldProbeServerStatus(force: force) else {
            return
        }

        updateServerStatusUI { [weak self] in
            self?.serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
            self?.serverStatusLabel.text = "Status: ElectrumX syncing..."
        }

        electrumXClient.checkConnection { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }

                if status.connected, let server = status.server {
                    self.setServerStatus(name: "ElectrumX", host: server.host, state: "connected")
                } else {
                    self.setServerStatus(name: "ElectrumX", host: nil, state: "error")
                }
            }
        }
    }

    private func setServerStatus(name: String, host: String?, state: String) {
        updateServerStatusUI { [weak self] in
            guard let self = self else {
                return
            }

            let connected = state == "connected"
            let errored = state == "error"
            self.serverStatusDot.backgroundColor = connected ? ThemeManager.shared.vergeGreen() : (errored ? ThemeManager.shared.vergeRed() : ThemeManager.shared.vergeGrey())

            if connected, let host = host {
                self.serverStatusLabel.text = "Status: \(name) connected to \(host)"
            } else if state == "syncing" {
                self.serverStatusLabel.text = "Status: \(name) syncing..."
            } else if errored {
                self.serverStatusLabel.text = "Status: \(name) connection error"
            } else if let host = host {
                self.serverStatusLabel.text = "Status: \(name) connecting to \(host)..."
            } else {
                self.serverStatusLabel.text = "Status: \(name) connecting..."
            }
        }
    }

    private func isWaitingForTor() -> Bool {
        return applicationRepository.useTor && !torClient.isOperational
    }

    private func activeBackendName() -> String {
        guard let mnemonic = applicationRepository.mnemonic,
              !applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic) else {
            return "VWS"
        }

        return "ElectrumX"
    }

    private func setSyncingStatus() {
        if isWaitingForTor() {
            setTorPendingStatus()
            return
        }

        setServerStatus(name: activeBackendName(), host: nil, state: "syncing")
    }

    private func setTorPendingStatus() {
        updateServerStatusUI { [weak self] in
            guard let self = self else {
                return
            }

            self.serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
            if self.torClient.hasStarted {
                self.serverStatusLabel.text = "Status: Tor bootstrapping \(self.torClient.bootstrapProgress)%..."
            } else {
                self.serverStatusLabel.text = "Status: Tor starting up..."
            }
        }
    }

    @objc private func didStartTorThread(notification: Notification) {
        updateServerStatusUI { [weak self] in
            self?.serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
            self?.serverStatusLabel.text = "Status: Tor starting up..."
        }
    }

    @objc private func didConnectTorController(notification: Notification) {
        updateServerStatusUI { [weak self] in
            self?.serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
            self?.serverStatusLabel.text = "Status: Tor bootstrapping \(self?.torClient.bootstrapProgress ?? 0)%..."
        }
    }

    @objc private func didUpdateTorBootstrapProgress(notification: Notification) {
        let progress = notification.userInfo?["progress"] as? Int
        let summary = notification.userInfo?["summary"] as? String
        updateServerStatusUI { [weak self] in
            guard let self = self else {
                return
            }

            self.serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
            let percent = progress ?? self.torClient.bootstrapProgress
            let phase = summary?.isEmpty == false ? " - \(summary!)" : ""
            self.serverStatusLabel.text = "Status: Tor bootstrapping \(percent)%\(phase)"
        }
    }

    @objc private func didEstablishTorConnection(notification: Notification) {
        updateServerStatusUI { [weak self] in
            guard let self = self else {
                return
            }

            self.serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
            self.serverStatusLabel.text = "Status: Tor connected, syncing \(self.activeBackendName())..."
            self.refreshServerStatus()
        }
    }

    @objc private func didFinishTorStart(notification: Notification) {
        guard applicationRepository.useTor else {
            return
        }

        updateServerStatusUI { [weak self] in
            guard let self = self else {
                return
            }

            self.serverStatusDot.backgroundColor = ThemeManager.shared.vergeGrey()
            self.serverStatusLabel.text = "Status: Tor ready, connecting to \(self.activeBackendName())..."
            self.refreshServerStatus()
        }
    }

    @objc private func didResignTorConnection(notification: Notification) {
        updateServerStatusUI { [weak self] in
            self?.serverStatusDot.backgroundColor = ThemeManager.shared.vergeRed()
            self?.serverStatusLabel.text = "Status: Tor disconnected"
        }
    }

    @objc private func didTurnOffTor(notification: Notification) {
        refreshServerStatus()
    }

    @objc private func errorDuringTorConnection(notification: Notification) {
        updateServerStatusUI { [weak self] in
            self?.serverStatusDot.backgroundColor = ThemeManager.shared.vergeRed()
            self?.serverStatusLabel.text = "Status: Tor connection error"
        }
    }

    private func updateServerStatusUI(_ updates: @escaping () -> Void) {
        if Thread.isMainThread {
            updates()
        } else {
            DispatchQueue.main.async(execute: updates)
        }
    }

}
