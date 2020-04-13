//
//  TorConnectionTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 03/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import MapKit
import Tor
import Promises

class TorConnectionTableViewController: EdgedTableViewController {

    @IBOutlet weak var useTorSwitch: UISwitch!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var applicationRepository: ApplicationRepository!
    var torClient: TorClient!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.useTorSwitch.setOn(self.applicationRepository.useTor, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.updateIPAddress()
    }

    @IBAction func changeTorUsage(_ sender: UISwitch) {
        applicationRepository.useTor = sender.isOn

        if sender.isOn {
            self.setIpAddressLabel("settings.torConnection.loadingLabel".localized)

            self.torClient.start { _ in
                self.updateIPAddress()
            }
        } else {
            self.torClient.resign()

            self.updateIPAddress()
        }
    }

    func updateIPAddress() {
        self.setIpAddressLabel("settings.torConnection.loadingLabel".localized)

        self.torClient.getCircuits().then { circuits in
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

            let torNodes = candidates.first?.nodes ?? []

            self.setupTorCircuitCells(nodes: torNodes)

            if let lastNode = torNodes.last, let ip = lastNode.ipv4Address ?? lastNode.ipv6Address {
                self.setIpAddressLabel(ip)
            }
        }.always {
            let url = URL(string: Constants.ipCheckEndpoint)
            let task = self.torClient.session.dataTask(with: url!) { data, _, error in
                do {
                    if data != nil {
                        let ipAddress = try JSONDecoder().decode(IpAddress.self, from: data!)

                        self.setIpAddressLabel(ipAddress.ip)
                        self.centerMapView(withIpLocation: ipAddress)
                    }
                } catch {
                    self.setIpAddressLabel("settings.torConnection.notAvailable".localized)

                    print(error)
                }
            }
            task.resume()
        }
    }

    func setIpAddressLabel(_ label: String) {
        DispatchQueue.main.async {
            self.ipAddressLabel.text = label
        }
    }

    func centerMapView(withIpLocation ipAddress: IpAddress) {
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

    private func setupTorCircuitCells(nodes: [TorNode]) {
        for (i, node) in nodes.enumerated() {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "torCircuitCountryCell\(i)") else {
                return
            }

            var label = node.localizedCountryName ?? node.countryCode ?? node.nickName ?? ""
            let ip = node.ipv4Address?.isEmpty ?? true ? node.ipv6Address : node.ipv4Address

            if i == 0 {
                label = "\(label) (Guard)"
            } else if i == 2 {
                label = "\(label) (You)"
            }

            cell.textLabel?.text = label
            cell.detailTextLabel?.text = ip
        }
    }

}
