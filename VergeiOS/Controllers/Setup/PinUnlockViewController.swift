//
//  PinUnlockViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 02-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import LocalAuthentication

class PinUnlockViewController: ThemeableViewController, KeyboardDelegate {

    enum UnlockState: String {
        case wallet
        case sending
    }

    @IBOutlet weak var pinKeyboard: PinKeyboard!
    @IBOutlet weak var pinTextField: PinTextField!
    @IBOutlet weak var closeButton: UIButton!

    static var storyBoardView: PinUnlockViewController?

    var applicationRepository: ApplicationRepository!
    var pin = ""
    var fillPinFor: UnlockState?
    var showLocalAuthentication = false
    var cancelable = false
    var completion: ((_ authenticated: Bool) -> Void)?

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    static func createFromStoryBoard() -> PinUnlockViewController {
        if PinUnlockViewController.storyBoardView == nil {
            PinUnlockViewController.storyBoardView = UIStoryboard(name: "Setup", bundle: nil)
                .instantiateViewController(withIdentifier: "PinUnlockViewController") as? PinUnlockViewController
        } else {
            PinUnlockViewController.storyBoardView!.reset()
        }

        if #available(iOS 13.0, *) {
            PinUnlockViewController.storyBoardView!.modalPresentationStyle = .fullScreen
        }

        return PinUnlockViewController.storyBoardView!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pinKeyboard.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didChangePinCharacterCount),
            name: .didChangePinCharacterCount,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if LAContext.anyAvailable() {
            if self.fillPinFor == .wallet {
                self.showLocalAuthentication = self.applicationRepository.localAuthForWalletUnlock
            } else if self.fillPinFor == .sending {
                self.showLocalAuthentication = self.applicationRepository.localAuthForSendingXvg
            }
        }

        if self.showLocalAuthentication {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.promptLocalAuthentication()
            }
        }

        self.pinKeyboard.setShowLocalAuthKey(self.showLocalAuthentication)
        self.closeButton.isHidden = !self.cancelable
        self.pinTextField.reset()
        self.pin = ""
    }

    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey) {
        if (keyboardKey.isKind(of: BackKey.self)) {
            self.pinTextField.removeCharacter()

            if (pin.count > 0) {
                self.pin = String(self.pin[..<self.pin.index(self.pin.endIndex, offsetBy: -1)])
            }
        } else if (keyboardKey.isKind(of: LocalAuthKey.self)) {
            self.promptLocalAuthentication()
        } else {
            self.pinTextField.addCharacter()

            if (self.pin.count < self.pinTextField.pinCharacterCount) {
                self.pin = "\(self.pin)\(input)"
            }

            // When all pins are set.
            if self.validate() {
                self.closeView()
            } else if self.pin.count == self.pinTextField.pinCharacterCount {
                self.pinTextField.shake()
                self.pinTextField.reset()
                self.pin = ""
            }
        }
    }

    // Validate the wallet pin.
    func validate() -> Bool {
        return self.pin.count == self.pinTextField.pinCharacterCount && self.applicationRepository.pin == self.pin
    }

    func promptLocalAuthentication() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Start by unlocking your wallet"

        var authError: NSError?
        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            myContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: myLocalizedReasonString
            ) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        // User authenticated successfully, take appropriate action
                        self.closeView()
                    }
                }
            }
        }
    }

    @objc private func didChangePinCharacterCount() {
        self.pinTextField.pinCharacterCount = self.applicationRepository.pinCount
        self.reset()
    }

    func closeView() {
        if self.completion != nil {
            self.completion?(true)
        } else {
            self.dismiss(animated: true)
        }
    }

    func cancelView() {
        if self.completion != nil {
            self.completion?(false)
        } else {
            self.dismiss(animated: true)
        }
    }

    @IBAction func closeButtonPushed(_ sender: Any) {
        self.cancelView()
    }

    func reset() {
        self.fillPinFor = nil
        self.cancelable = false
        self.showLocalAuthentication = false
        self.completion = nil

        self.pinTextField.reset()
        self.pin = ""
    }
}
