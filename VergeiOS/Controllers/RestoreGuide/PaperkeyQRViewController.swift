//
//  PaperkeyQRViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 09/12/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import AVFoundation

class PaperkeyQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var overlayView: UIView!

    var paperkeyViewController: EnterRecoveryKeyController!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var capturedMnemonic: Bool = false

    var statusBarShouldBeHidden = false

    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            captureSession = AVCaptureSession()

            // Set the input device on the capture session.
            captureSession?.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        self.view.bringSubviewToFront(self.overlayView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Show the status bar
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Start video capture.
        captureSession?.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if capturedMnemonic {
                return
            }

            let mnemonic = metadataObj.stringValue?.split(separator: " ")
            if mnemonic?.count == 12 {
                capturedMnemonic = true

                var newMnemonic: [String] = []
                for word in mnemonic ?? [] {
                    newMnemonic.append(String(word))
                }

                paperkeyViewController.setMnemonicAndProceed(newMnemonic)

                closeController(self)
            }
        }
    }


    // MARK: - Navigation

    @IBAction func closeController(_ sender: Any) {
        dismiss(animated: true) {
            self.captureSession?.stopRunning()
        }
    }

}
