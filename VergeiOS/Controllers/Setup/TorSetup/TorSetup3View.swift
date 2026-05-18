//
//  TorSetup3View.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import Logging

class TorSetup3View: UIView {

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
        applyReadableTheme()

//        self.updateIPAddress()
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
            DispatchQueue.global(qos: .userInitiated).async {
                self.torClient.start { _ in
                    DispatchQueue.main.async {
                        self.updateIPAddress()
                    }
                }
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                self.torClient.resign()

                DispatchQueue.main.async {
                    self.updateIPAddress()

                    // Notify the whole application.
                    NotificationCenter.default.post(name: .didTurnOffTor, object: self)
                }
            }
        }
    }


    func updateIPAddress() {
        let url = URL(string: Constants.ipCheckEndpoint)

        self.httpSession.dataTask(with: url!).then { response in
            _ = try response.dataToJson(type: IpAddress.self)
        }.catch { error in
            self.log.error("tor setup error while fetching your ip: \(error)")
        }
    }

    @IBAction func proceed(_ sender: Any) {
        self.viewController.performSegue(withIdentifier: "createWallet", sender: self)
    }

    private func applyReadableTheme() {
        backgroundColor = UIColor(rgb: 0x080212)
        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.setTitleColor(UIColor.white.withAlphaComponent(0.72), for: .disabled)
        proceedButton.tintColor = .white
        proceedButton.backgroundColor = UIColor(rgb: 0x3A125C)
        proceedButton.layer.cornerRadius = 10
        proceedButton.layer.borderWidth = 1
        proceedButton.layer.borderColor = UIColor(rgb: 0xFF3DF2).withAlphaComponent(0.72).cgColor
        proceedButton.clipsToBounds = true
        proceedButton.titleLabel?.textAlignment = .center
        proceedButton.titleLabel?.adjustsFontSizeToFitWidth = true
        proceedButton.titleLabel?.minimumScaleFactor = 0.82
        proceedButton.contentHorizontalAlignment = .center
        proceedButton.contentVerticalAlignment = .center

        applyReadableText(in: self)
    }

    private func applyReadableText(in root: UIView) {
        for subview in root.subviews {
            if let label = subview as? UILabel {
                label.textColor = label.font.pointSize >= 20
                    ? ThemeManager.shared.primaryLight()
                    : ThemeManager.shared.secondaryLight()
                label.backgroundColor = .clear
            } else if let textView = subview as? UITextView {
                textView.textColor = ThemeManager.shared.secondaryLight()
                textView.backgroundColor = .clear
            } else if !(subview is UIControl) && !(subview is UIImageView) {
                subview.backgroundColor = .clear
            }

            if !(subview is UIControl) {
                applyReadableText(in: subview)
            }
        }
    }

}
