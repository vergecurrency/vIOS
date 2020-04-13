//
//  TorSettingsTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13/04/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import UIKit
import Promises
import MapKit
import Tor

class TorSettingsTableViewController: EdgedTableViewController {

    typealias CellRenderer = () -> UITableViewCell

    var applicationRepository: ApplicationRepository!
    var torClient: TorClient!

    private var torSwitch = UISwitch()
    private var mapView = MKMapView()

    private var torIsConnected: Bool {
        return true
    }

    private var cells: [Int: [CellRenderer]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.cells[0] = []
        self.cells[0]?.append({
            let cell = UITableViewCell()
            cell.textLabel?.text = "settings.torConnection.obfuscateIpLabel".localized
            cell.accessoryView = self.torSwitch

            self.torSwitch.setOn(self.applicationRepository.useTor, animated: false)

            return cell
        })

        self.loadCurrentIp().then(self.loadTorCircuit).then { _ in
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return torIsConnected ? 3 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells[section]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.cells[indexPath.section]?[indexPath.row]() else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        cell.updateColors()

        cell.textLabel?.font = UIFont.avenir(size: 17)
        cell.detailTextLabel?.font = UIFont.avenir(size: 17).demiBold()

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 && indexPath.row == 1 ? 300 : 44
    }

    private func loadCurrentIp() -> Promise<Bool> {
        return Promise { fulfill, reject in
            let url = URL(string: Constants.ipCheckEndpoint)
            let task = self.torClient.session.dataTask(with: url!) { data, _, error in
                do {
                    if data != nil {
                        let ipAddress = try JSONDecoder().decode(IpAddress.self, from: data!)

                        self.cells[1] = []
                        self.cells[1]?.append({
                            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                            cell.textLabel?.text = "settings.torConnection.yourIpLabel".localized
                            cell.detailTextLabel?.text = ipAddress.ip

                            return cell
                        })
                        self.cells[1]?.append({
                            let cell = UITableViewCell()

                            self.mapView.translatesAutoresizingMaskIntoConstraints = false
                            cell.contentView.addSubview(self.mapView)
                            self.mapView.pinEdges(to: cell.contentView)
                            self.centerMapView(withIpLocation: ipAddress)

                            return cell
                        })

                        fulfill(true)
                    }
                } catch {
                    reject(error)
                }
            }
            task.resume()
        }
    }

    private func loadTorCircuit(_ success: Bool) -> Promise<Bool> {
        return self.torClient.getCircuits().then { circuits in
            var candidates: [TorCircuit] = []

            for circuit in circuits {
                if circuit.purpose == TorCircuit.purposeGeneral
                    && !(circuit.socksUsername?.isEmpty ?? true)
                    && !(circuit.buildFlags?.contains(TorCircuit.buildFlagIsInternal) ?? false)
                    && !(circuit.buildFlags?.contains(TorCircuit.buildFlagOneHopTunnel) ?? false) {

                    candidates.append(circuit)
                }
            }

            candidates.sort {
                $0.timeCreated ?? Date(timeIntervalSince1970: 0) < $1.timeCreated ?? Date(timeIntervalSince1970: 0)
            }

            var nodes: [CellRenderer] = []
            for node in candidates.first?.nodes ?? [] {
                nodes.append({
                    let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                    cell.textLabel?.text = node.localizedCountryName ?? node.countryCode ?? node.nickName ?? ""
                    cell.detailTextLabel?.text = node.ipv4Address?.isEmpty ?? true ? node.ipv6Address : node.ipv4Address

                    return cell
                })
            }

            self.cells[2] = nodes

            return Promise { true }
        }
    }

    private func centerMapView(withIpLocation ipAddress: IpAddress) {
        let coordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(ipAddress.latitude),
            longitude: CLLocationDegrees(ipAddress.longitude)
        )

        let distance: CLLocationDistance = 12000
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: distance, longitudinalMeters: distance)

        DispatchQueue.main.async {
            self.mapView.setCenter(coordinate, animated: true)
            self.mapView.setRegion(region, animated: true)
        }
    }
}
