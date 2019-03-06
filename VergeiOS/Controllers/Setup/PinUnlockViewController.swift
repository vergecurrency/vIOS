//
//  PinUnlockViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 02-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import LocalAuthentication

class PinUnlockViewController: UIViewController, KeyboardDelegate {

    enum UnlockState: String {
        case wallet
        case sending
    }

    @IBOutlet weak var pinKeyboard: PinKeyboard!
    @IBOutlet weak var pinTextField: PinTextField!
    @IBOutlet weak var closeButton: UIButton!
    
    static var storyBoardView: PinUnlockViewController? = nil
    
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

        return PinUnlockViewController.storyBoardView!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pinKeyboard.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if LAContext.anyAvailable() {
            if fillPinFor == .wallet {
                showLocalAuthentication = ApplicationRepository.default.localAuthForWalletUnlock
            } else if fillPinFor == .sending {
                showLocalAuthentication = ApplicationRepository.default.localAuthForSendingXvg
            }
        }

        if showLocalAuthentication {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.promptLocalAuthentication()
            }
        }

        pinKeyboard.setShowLocalAuthKey(showLocalAuthentication)
        closeButton.isHidden = !cancelable
        pinTextField.reset()
        pin = ""
    }

    func didReceiveInput(_ sender: Keyboard, input: String, keyboardKey: KeyboardKey) {
        if (keyboardKey.isKind(of: BackKey.self)) {
            self.pinTextField.removeCharacter()

            if (pin.count > 0) {
                pin = String(pin[..<pin.index(pin.endIndex, offsetBy: -1)])
            }
        } else if (keyboardKey.isKind(of: LocalAuthKey.self)) {
            promptLocalAuthentication()
        } else {
            self.pinTextField.addCharacter()
            
            if (pin.count < self.pinTextField.pinCharacterCount) {
                pin = "\(pin)\(input)"
            }
            
            // When all pins are set.
            if self.validate() {
                closeView()
            } else if pin.count == self.pinTextField.pinCharacterCount {
                pinTextField.shake()
                pinTextField.reset()
                pin = ""
            }
        }
    }
    
    // Validate the wallet pin.
    func validate() -> Bool {
        return pin.count == self.pinTextField.pinCharacterCount && ApplicationRepository.default.pin == pin
    }

    func promptLocalAuthentication() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Start by unlocking your wallet"

        var authError: NSError?
        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            myContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: myLocalizedReasonString
            ) { success, evaluateError in
                DispatchQueue.main.async {
                    if success {
                        // User authenticated successfully, take appropriate action
                        self.closeView()
                    }
                }
            }
        }
    }

    func closeView() {
        if completion != nil {
            completion?(true)
        } else {
            dismiss(animated: true)
        }
    }

    func cancelView() {
        if completion != nil {
            completion?(false)
        } else {
            dismiss(animated: true)
        }
    }

    @IBAction func closeButtonPushed(_ sender: Any) {
        cancelView()
    }

    func reset() {
        fillPinFor = nil
        cancelable = false
        showLocalAuthentication = false
        completion = nil

        pinTextField.reset()
        pin = ""
    }

}
