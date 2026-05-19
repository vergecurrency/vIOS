//
//  TorConnectionTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 03/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TorConnectionTableViewController: EdgedTableViewController {

    @IBOutlet weak var useTorSwitch: UISwitch!
    @IBOutlet weak var ipAddressLabel: UILabel!

    var applicationRepository: ApplicationRepository!
    var torClient: TorClient!

    private let torStatusContainer = UIView()
    private let torStatusDot = UIView()
    private let torStatusTitleLabel = UILabel()
    private let torStatusDetailLabel = UILabel()
    private var didSetupTorStatus = false
    private var didAttachTorStatus = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        useTorSwitch.setOn(applicationRepository.useTor, animated: false)
        setupTorStatusBox()
        subscribeToTorStatus()
        refreshTorStatusFromClient()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        attachTorStatusBoxToCell()
        refreshTorStatusFromClient()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        attachTorStatusBoxToCell()
    }

    @IBAction func changeTorUsage(_ sender: UISwitch) {
        applicationRepository.useTor = sender.isOn

        if sender.isOn {

            setTorStatus("Tor starting up", detail: "Starting privacy connection", color: ThemeManager.shared.vergeGrey())

            // prevent double-start crash
            if !torClient.hasStarted {
                torClient.start { _ in }
            } else if torClient.isOperational {
                setTorStatus("Tor connected", detail: "Wallet traffic is routing through Tor", color: ThemeManager.shared.vergeGreen())
            } else {
                setTorStatus("Tor bootstrapping", detail: "Waiting for a Tor circuit", color: ThemeManager.shared.vergeGrey())
            }

        } else {
            torClient.resign()
            setTorStatus("Tor is off", detail: "Privacy routing is disabled", color: ThemeManager.shared.vergeRed())
            NotificationCenter.default.post(name: .didTurnOffTor, object: self)
        }
    }

    private func setupTorStatusBox() {
        guard !didSetupTorStatus else {
            return
        }

        didSetupTorStatus = true

        torStatusContainer.translatesAutoresizingMaskIntoConstraints = false
        torStatusContainer.backgroundColor = ThemeManager.shared.backgroundGrey().withAlphaComponent(0.88)
        torStatusContainer.layer.cornerRadius = 18
        torStatusContainer.layer.borderWidth = 1
        torStatusContainer.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.42).cgColor
        torStatusContainer.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        torStatusContainer.layer.shadowOpacity = 0.2
        torStatusContainer.layer.shadowRadius = 12
        torStatusContainer.layer.shadowOffset = CGSize(width: 0, height: 0)

        torStatusDot.translatesAutoresizingMaskIntoConstraints = false
        torStatusDot.layer.cornerRadius = 6

        torStatusTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        torStatusTitleLabel.font = UIFont.avenir(size: 15)
        torStatusTitleLabel.textColor = ThemeManager.shared.secondaryLight()

        torStatusDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        torStatusDetailLabel.font = UIFont.avenir(size: 12)
        torStatusDetailLabel.textColor = ThemeManager.shared.secondaryLight().withAlphaComponent(0.82)
        torStatusDetailLabel.numberOfLines = 2

        torStatusContainer.addSubview(torStatusDot)
        torStatusContainer.addSubview(torStatusTitleLabel)
        torStatusContainer.addSubview(torStatusDetailLabel)

        NSLayoutConstraint.activate([
            torStatusDot.leadingAnchor.constraint(equalTo: torStatusContainer.leadingAnchor, constant: 16),
            torStatusDot.topAnchor.constraint(equalTo: torStatusContainer.topAnchor, constant: 18),
            torStatusDot.widthAnchor.constraint(equalToConstant: 12),
            torStatusDot.heightAnchor.constraint(equalToConstant: 12),

            torStatusTitleLabel.leadingAnchor.constraint(equalTo: torStatusDot.trailingAnchor, constant: 10),
            torStatusTitleLabel.trailingAnchor.constraint(equalTo: torStatusContainer.trailingAnchor, constant: -16),
            torStatusTitleLabel.topAnchor.constraint(equalTo: torStatusContainer.topAnchor, constant: 14),

            torStatusDetailLabel.leadingAnchor.constraint(equalTo: torStatusTitleLabel.leadingAnchor),
            torStatusDetailLabel.trailingAnchor.constraint(equalTo: torStatusTitleLabel.trailingAnchor),
            torStatusDetailLabel.topAnchor.constraint(equalTo: torStatusTitleLabel.bottomAnchor, constant: 4),
            torStatusDetailLabel.bottomAnchor.constraint(lessThanOrEqualTo: torStatusContainer.bottomAnchor, constant: -14)
        ])
    }

    private func attachTorStatusBoxToCell() {
        guard !didAttachTorStatus,
              let statusCell = ipAddressLabel.firstSuperview(ofType: UITableViewCell.self) else {
            return
        }

        didAttachTorStatus = true
        statusCell.selectionStyle = .none
        statusCell.backgroundColor = .clear
        statusCell.contentView.backgroundColor = .clear
        statusCell.textLabel?.isHidden = true
        statusCell.detailTextLabel?.isHidden = true
        ipAddressLabel.isHidden = true

        torStatusContainer.removeFromSuperview()
        statusCell.contentView.addSubview(torStatusContainer)

        let guide = statusCell.contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            torStatusContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            torStatusContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            torStatusContainer.topAnchor.constraint(equalTo: statusCell.contentView.topAnchor, constant: 8),
            torStatusContainer.bottomAnchor.constraint(equalTo: statusCell.contentView.bottomAnchor, constant: -8),
            torStatusContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 76)
        ])
    }

    private func subscribeToTorStatus() {
        let notifications: [Notification.Name: Selector] = [
            .didStartTorThread: #selector(didStartTorThread(notification:)),
            .didConnectTorController: #selector(didConnectTorController(notification:)),
            .didUpdateTorBootstrapProgress: #selector(didUpdateTorBootstrapProgress(notification:)),
            .didEstablishTorConnection: #selector(didEstablishTorConnection(notification:)),
            .didFinishTorStart: #selector(didFinishTorStart(notification:)),
            .didResignTorConnection: #selector(didResignTorConnection(notification:)),
            .didTurnOffTor: #selector(didTurnOffTor(notification:)),
            .errorDuringTorConnection: #selector(errorDuringTorConnection(notification:))
        ]

        notifications.forEach { name, selector in
            NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
        }
    }

    private func setTorStatus(_ title: String, detail: String, color: UIColor) {
        DispatchQueue.main.async {
            self.torStatusDot.backgroundColor = color
            self.torStatusTitleLabel.text = title
            self.torStatusDetailLabel.text = detail
        }
    }

    private func refreshTorStatusFromClient() {
        if !applicationRepository.useTor {
            setTorStatus("Tor is off", detail: "Privacy routing is disabled", color: ThemeManager.shared.vergeRed())
        } else if torClient.isOperational {
            setTorStatus("Tor connected", detail: "Wallet traffic is routing through Tor", color: ThemeManager.shared.vergeGreen())
        } else if torClient.hasStarted {
            setTorBootstrapStatus()
        } else {
            setTorStatus("Tor starting up", detail: "Waiting for privacy connection", color: ThemeManager.shared.vergeGrey())
        }
    }

    @objc private func didStartTorThread(notification: Notification) {
        setTorStatus("Tor starting up", detail: "Starting local Tor service", color: ThemeManager.shared.vergeGrey())
    }

    @objc private func didConnectTorController(notification: Notification) {
        setTorBootstrapStatus(fallbackDetail: "Controller connected, building a circuit")
    }

    @objc private func didUpdateTorBootstrapProgress(notification: Notification) {
        let progress = notification.userInfo?["progress"] as? Int
        let summary = notification.userInfo?["summary"] as? String
        setTorBootstrapStatus(progress: progress, summary: summary)
    }

    @objc private func didEstablishTorConnection(notification: Notification) {
        setTorStatus("Tor connected", detail: "Wallet traffic is routing through Tor", color: ThemeManager.shared.vergeGreen())
    }

    @objc private func didFinishTorStart(notification: Notification) {
        if applicationRepository.useTor {
            setTorStatus("Tor connected", detail: "Privacy connection is ready", color: ThemeManager.shared.vergeGreen())
        }
    }

    @objc private func didResignTorConnection(notification: Notification) {
        setTorStatus("Tor disconnected", detail: "Privacy connection stopped", color: ThemeManager.shared.vergeRed())
    }

    @objc private func didTurnOffTor(notification: Notification) {
        setTorStatus("Tor is off", detail: "Privacy routing is disabled", color: ThemeManager.shared.vergeRed())
    }

    @objc private func errorDuringTorConnection(notification: Notification) {
        setTorStatus("Tor connection error", detail: "Could not complete privacy connection", color: ThemeManager.shared.vergeRed())
    }

    private func setTorBootstrapStatus(
        progress: Int? = nil,
        summary: String? = nil,
        fallbackDetail: String = "Waiting for a Tor circuit"
    ) {
        let percent = progress ?? torClient.bootstrapProgress
        let statusSummary = summary?.isEmpty == false ? summary! : (torClient.bootstrapSummary ?? fallbackDetail)
        let title = "Tor bootstrapping \(percent)%"
        setTorStatus(title, detail: statusSummary, color: ThemeManager.shared.vergeGrey())
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 104
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }

}

private extension UIView {

    func firstSuperview<T: UIView>(ofType type: T.Type) -> T? {
        if let superview = self.superview as? T {
            return superview
        }

        return superview?.firstSuperview(ofType: type)
    }

}
