//
//  TorSetup3View.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import MapKit
import Logging

class TorSetup3View: UIView {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var proceedButton: UIButton!

    var viewController: TorViewController!
    var applicationRepository: ApplicationRepository!
    var torClient: TorClient!
    var httpSession: HttpSessionProtocol!
    var log: Logger!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.applicationRepository = Application.container.resolve(ApplicationRepository.self)!
        self.torClient = Application.container.resolve(TorClient.self)!
        self.httpSession = Application.container.resolve(HttpSessionProtocol.self)!
        self.log = Application.container.resolve(Logger.self)!

        self.updateIPAddress()
    }

    @IBAction func changeTorUsage(_ sender: UISwitch) {
        self.applicationRepository.useTor = sender.isOn

        proceedButton.setTitle(
            sender.isOn ?
                "setup.tor.slide3.positiveButton".localized :
                "setup.tor.slide3.negativeButton".localized,
            for: .normal
        )

        if sender.isOn {
            self.torClient.start { _ in
                self.updateIPAddress()
            }
        } else {
            self.torClient.resign()

            self.updateIPAddress()

            // Notify the whole application.
            NotificationCenter.default.post(name: .didTurnOffTor, object: self)
        }
    }

    func updateIPAddress() {
        let url = URL(string: Constants.ipCheckEndpoint)

        self.httpSession.dataTask(with: url!).then { response in
            self.centerMapView(withIpLocation: try response.dataToJson(type: IpAddress.self))
        }.catch { error in
            self.log.error("tor setup error while fetching your ip: \(error)")
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

    @IBAction func proceed(_ sender: Any) {
        self.viewController.performSegue(withIdentifier: "createWallet", sender: self)
    }

}
