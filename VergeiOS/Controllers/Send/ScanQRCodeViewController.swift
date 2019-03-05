//
//  ScanQRCodeViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var flashButton: UIButton!

    weak var sendTransactionDelegate: SendTransactionDelegate!
    var sendTransaction: TransactionFactory?
    
    var captureSession: AVCaptureSession?
    var captureDevice: AVCaptureDevice?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    var imagePicker = UIImagePickerController()
    
    var statusBarShouldBeHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    @IBOutlet weak var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        sendTransaction = sendTransactionDelegate.getSendTransaction()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: .back
        )
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        self.captureDevice = captureDevice

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            AddressValidator().validate(metadataObject: metadataObj) { (valid, address, amount) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.closeController(self)
                }
                
                if !valid {
                    return
                }
                
                self.sendTransaction?.address = address!
                
                if amount != nil {
                    self.sendTransaction?.amount = amount!
                }
                
                self.sendTransactionDelegate.didChangeSendTransaction(self.sendTransaction!)
            }
        }
    }

    func flash(turnOff: Bool = false) {
        guard let device = captureDevice else { return }
        guard device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on || turnOff) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }

            device.unlockForConfiguration()
        } catch {
            print(error)
        }

        if device.torchMode == .on {
            flashButton.setImage(UIImage(named: "FlashOff"), for: .normal)
        } else {
            flashButton.setImage(UIImage(named: "FlashOn"), for: .normal)
        }
    }

    @IBAction func toggleFlash(_ sender: Any) {
        flash()
    }

    @IBAction func openImage(_ sender: Any) {
        present(imagePicker, animated: true)
    }

    // MARK: - Navigation

    @IBAction func closeController(_ sender: Any) {
        dismiss(animated: true) {
            self.captureSession?.stopRunning()
            self.flash(turnOff: true)
        }
    }
}

extension ScanQRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            let detector = CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            )!
            let ciImage = CIImage(image: image)!
            var qrCode = ""

            let features = detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCode += feature.messageString!
            }

            AddressValidator().validate(string: qrCode) { (valid, address, amount) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.closeController(self)
                }

                if !valid {
                    return
                }

                self.sendTransaction?.address = address!

                if amount != nil {
                    self.sendTransaction?.amount = amount!
                }

                self.sendTransactionDelegate.didChangeSendTransaction(self.sendTransaction!)
            }
        }

        dismiss(animated: true, completion: nil)
    }
}
