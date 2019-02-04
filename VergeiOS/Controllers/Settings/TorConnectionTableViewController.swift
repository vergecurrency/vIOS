//
//  TorConnectionTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 03/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import MapKit

class TorConnectionTableViewController: EdgedTableViewController {

    @IBOutlet weak var useTorSwitch: UISwitch!
    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        useTorSwitch.setOn(ApplicationRepository.default.useTor, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateIPAddress()
    }
    
    @IBAction func changeTorUsage(_ sender: UISwitch) {
        ApplicationRepository.default.useTor = sender.isOn
        
        if sender.isOn {
            setIpAddressLabel("Loading...")
            
            TorClient.shared.start {
                self.updateIPAddress()
            }
        } else {
            TorClient.shared.resign()
            
            self.updateIPAddress()
            
            // Notify the whole application.
            NotificationCenter.default.post(name: .didTurnOffTor, object: self)
        }
    }
    
    func updateIPAddress() {
        setIpAddressLabel("Loading...")

        let url = URL(string: Constants.ipCheckEndpoint)
        let task = TorClient.shared.session.dataTask(with: url!) { data, response, error in
            do {
                if data != nil {
                    let ipAddress = try JSONDecoder().decode(IpAddress.self, from: data!)

                    self.setIpAddressLabel(ipAddress.ip)
                    self.centerMapView(withIpLocation: ipAddress)
                }
            } catch {
                self.setIpAddressLabel("Service not available")

                print(error)
            }
        }
        task.resume()
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

}
