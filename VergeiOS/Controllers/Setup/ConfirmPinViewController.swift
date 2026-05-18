//
//  ConfirmPinViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 25-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ConfirmPinViewController: ThemeableViewController, KeyboardDelegate {

    @IBOutlet weak var pinTextField: PinTextField!
    @IBOutlet weak var pinKeyboard: PinKeyboard!
    @IBOutlet weak var pinConfirmedView: PanelView!
    @IBOutlet weak var pinFailedView: PanelView!

    var applicationRepository: ApplicationRepository!
    var previousPin: String = ""
    var pin: String = ""
    var pinCount: Int!
    var segueIdentifier: String?
    var completion: ((_ pin: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        pinKeyboard.delegate = self
        pinConfirmedView.isHidden = true
        pinFailedView.isHidden = true
        pinTextField.pinCharacterCount = pinCount
        pinTextField.reset()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
        configureNavigationButtons()
    }

    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey) {
        if (keyboardKey.isKind(of: BackKey.self)) {
            self.pinTextField.removeCharacter()

            if (pin.count > 0) {
                pin = String(pin[..<pin.index(pin.endIndex, offsetBy: -1)])
            }
        } else {
            self.pinTextField.addCharacter()

            if (pin.count < self.pinTextField.pinCharacterCount) {
                pin = "\(pin)\(input)"
            }

            // When all pins are set.
            if (pin.count == self.pinTextField.pinCharacterCount) {
                self.handlePinCreation()
            }
        }
    }

    func handlePinCreation() {
        if (self.pin == self.previousPin) {
            self.applicationRepository.pinCount = self.pinCount

            NotificationCenter.default.post(name: .didChangePinCharacterCount, object: self.pinCount)

            self.pinConfirmedView.alpha = 0.0
            self.pinConfirmedView.center.y -= 60.0
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
                self.pinKeyboard.alpha = 0.0

                self.pinConfirmedView.isHidden = false
                self.pinConfirmedView.alpha = 1.0
                self.pinConfirmedView.center.y += 60.0
            }, completion: nil)
        } else {
            self.pinFailedView.alpha = 0.0
            self.pinFailedView.center.y -= 60
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut, animations: {
                self.pinKeyboard.alpha = 0.0

                self.pinFailedView.isHidden = false
                self.pinFailedView.alpha = 1.0
                self.pinFailedView.center.y += 60.0

            }, completion: nil)
        }
    }

    @IBAction func confirmPin(_ sender: Any) {
        self.applicationRepository.pin = self.pin

        if let completion = completion {
            return completion(self.pin)
        }

        if let si = segueIdentifier {
            performSegue(withIdentifier: si, sender: nil)
        }
    }

    @objc private func backToPinSelection(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    private func configureNavigationButtons() {
        let backButton = makePinBarButton(title: "Back", width: 82)
        backButton.addTarget(self, action: #selector(backToPinSelection(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    private func makePinBarButton(title: String, width: CGFloat) -> UIControl {
        let button = UIControl()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(rgb: 0x24103A)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = ThemeManager.shared.primaryLight().withAlphaComponent(0.65).cgColor
        button.layer.shadowColor = ThemeManager.shared.primaryLight().cgColor
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 0)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.avenir(size: 14).demiBold()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        label.isUserInteractionEnabled = false
        button.addSubview(label)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: width),
            button.heightAnchor.constraint(equalToConstant: 34),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: button.topAnchor),
            label.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])

        return button
    }

}
