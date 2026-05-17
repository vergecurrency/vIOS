import UIKit

final class ElectrumXServersTableViewController: EdgedTableViewController {
    var applicationRepository: ApplicationRepository!
    var electrumXClient: ElectrumXClient!

    private let statusDot = UIView()
    private let statusLabel = UILabel()

    private var servers: [ElectrumXServer] {
        return applicationRepository.electrumXServers
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "ElectrumX Servers"
        view.backgroundColor = ThemeManager.shared.backgroundGrey()
        tableView.backgroundColor = ThemeManager.shared.backgroundGrey()
        tableView.separatorColor = ThemeManager.shared.separatorColor()
        tableView.indicatorStyle = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addServer)
        )
        setupStatusPill()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshStatus()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? servers.count : 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Servers" : "Actions"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 0 else {
            return nil
        }

        return "These servers are stored for the ElectrumX backend. The default Verge hosts are electrumx-verge.cloud and electrum-verge.cloud."
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = indexPath.section == 0 ? "ElectrumXServerCell" : "ElectrumXActionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: indexPath.section == 0 ? .subtitle : .default, reuseIdentifier: reuseIdentifier)

        styleCellShell(cell)
        cell.accessoryType = .none
        cell.selectionStyle = indexPath.section == 0 ? .none : .default
        cell.detailTextLabel?.text = nil

        if indexPath.section == 0 {
            let server = servers[indexPath.row]
            cell.textLabel?.text = server.displayName
            cell.detailTextLabel?.text = "\(server.scheme.uppercased()) port \(server.port)"
            cell.accessoryType = server == applicationRepository.activeElectrumXServer ? .checkmark : .none
            cell.textLabel?.font = UIFont.avenir(size: 17)
            cell.detailTextLabel?.font = UIFont.avenir(size: 12)
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = ThemeManager.shared.secondaryLight()
        } else {
            cell.textLabel?.text = indexPath.row == 0 ? "Add ElectrumX server" : "Restore default servers"
            styleActionCell(cell)
        }

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        styleCellShell(cell)
        if indexPath.section == 1 {
            styleActionCell(cell)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }

        header.contentView.backgroundColor = ThemeManager.shared.backgroundGrey()
        header.textLabel?.textColor = ThemeManager.shared.primaryLight()
        header.textLabel?.font = UIFont.avenir(size: 13).demiBold()
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? UITableViewHeaderFooterView else {
            return
        }

        footer.contentView.backgroundColor = ThemeManager.shared.backgroundGrey()
        footer.textLabel?.textColor = ThemeManager.shared.secondaryLight()
        footer.textLabel?.font = UIFont.avenir(size: 12)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else {
            return
        }

        applicationRepository.removeElectrumXServer(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        refreshStatus()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            applicationRepository.activeElectrumXServer = servers[indexPath.row]
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            refreshStatus()
            return
        }

        if indexPath.row == 0 {
            addServer()
        } else {
            applicationRepository.resetElectrumXServers()
            tableView.reloadData()
            refreshStatus()
        }
    }

    @objc private func addServer() {
        let alert = UIAlertController(title: "Add ElectrumX Server", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Host"
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        alert.addTextField { textField in
            textField.placeholder = "Port"
            textField.text = "50002"
            textField.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            let rawHost = alert.textFields?[0].text ?? ""
            let host = self.normalizedHost(rawHost)
            let portText = alert.textFields?[1].text ?? ""
            let port = Int(portText) ?? 50002

            guard !host.isEmpty else {
                return
            }

            self.applicationRepository.addElectrumXServer(
                ElectrumXServer(host: host, port: port, useTLS: true)
            )
            self.tableView.reloadData()
            self.refreshStatus()
        })

        present(alert, animated: true)
    }

    private func normalizedHost(_ rawHost: String) -> String {
        var host = rawHost.trimmingCharacters(in: .whitespacesAndNewlines)
        host = host.replacingOccurrences(of: "https://", with: "")
        host = host.replacingOccurrences(of: "http://", with: "")
        host = host.replacingOccurrences(of: "ssl://", with: "")
        host = host.replacingOccurrences(of: "tcp://", with: "")

        if let slashIndex = host.firstIndex(of: "/") {
            host = String(host[..<slashIndex])
        }

        if let colonIndex = host.firstIndex(of: ":") {
            host = String(host[..<colonIndex])
        }

        return host
    }

    private func styleCellShell(_ cell: UITableViewCell) {
        cell.backgroundColor = ThemeManager.shared.backgroundWhite()
        cell.contentView.backgroundColor = .clear
        cell.tintColor = ThemeManager.shared.primaryLight()
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = false
        cell.layer.borderWidth = 1
        cell.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.25).cgColor
        cell.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        cell.layer.shadowOpacity = 0.12
        cell.layer.shadowRadius = 8
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)

        let selectedView = UIView()
        selectedView.backgroundColor = ThemeManager.shared.backgroundBlue()
        cell.selectedBackgroundView = selectedView
    }

    private func styleActionCell(_ cell: UITableViewCell) {
        cell.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        cell.textLabel?.textColor = .white
        cell.textLabel?.textAlignment = .center
        cell.accessoryType = .none
        cell.selectionStyle = .default
        cell.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.7).cgColor
        cell.layer.shadowColor = UIColor(rgb: 0xFF3DF2).cgColor
        cell.layer.shadowOpacity = 0.28
        cell.layer.shadowRadius = 12
    }

    private func setupStatusPill() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 58))
        header.backgroundColor = ThemeManager.shared.backgroundGrey()
        let pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = ThemeManager.shared.backgroundWhite()
        pill.layer.cornerRadius = 18
        pill.layer.borderWidth = 1
        pill.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.38).cgColor
        pill.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        pill.layer.shadowOpacity = 0.18
        pill.layer.shadowRadius = 10
        pill.layer.shadowOffset = CGSize(width: 0, height: 0)

        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.layer.cornerRadius = 5
        statusDot.backgroundColor = ThemeManager.shared.vergeGrey()

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.avenir(size: 13)
        statusLabel.textColor = ThemeManager.shared.secondaryLight()
        statusLabel.text = "ElectrumX: checking..."
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.8

        header.addSubview(pill)
        pill.addSubview(statusDot)
        pill.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            pill.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            pill.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            pill.topAnchor.constraint(equalTo: header.topAnchor, constant: 10),
            pill.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8),

            statusDot.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 14),
            statusDot.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 10),
            statusDot.heightAnchor.constraint(equalToConstant: 10),

            statusLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -14),
            statusLabel.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
        ])

        tableView.tableHeaderView = header
    }

    private func refreshStatus() {
        statusDot.backgroundColor = ThemeManager.shared.vergeGrey()
        statusLabel.text = "ElectrumX: checking..."

        electrumXClient.checkConnection { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }

                if status.connected, let server = status.server {
                    self.statusDot.backgroundColor = ThemeManager.shared.vergeGreen()
                    self.statusLabel.text = "ElectrumX: connected to \(server.host)"
                } else {
                    self.statusDot.backgroundColor = ThemeManager.shared.vergeRed()
                    self.statusLabel.text = "ElectrumX: not connected"
                }
            }
        }
    }
}
