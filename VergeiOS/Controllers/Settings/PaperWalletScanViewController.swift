//
// Created by Swen van Zanten on 2019-07-17.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import UIKit
import AVFoundation

class PaperWalletScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var qrCodeFrameView: UIView!
    var imagePicker = UIImagePickerController()
    var captureSession: AVCaptureSession?
    var captureDevice: AVCaptureDevice?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    var qrCutoutView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 240))
        view.backgroundColor = ThemeManager.shared.primaryDark()

        return view
    }()

    var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)

        return view
    }()

    var scanLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = .avenir(size: 17)
        label.text = "Scan paper wallet private key"

        return label
    }()

    var buttonsStackView: UIStackView = {
        let stack = UIStackView()

        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .fill
        stack.distribution = .fillEqually

        return stack
    }()

    var flashButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "FlashOn"), for: .normal)

        return button
    }()

    var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("send.qrcode.closeButton".localized, for: .normal)

        return button
    }()

    var imageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Image"), for: .normal)

        return button
    }()


    var statusBarShouldBeHidden = false

    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override func loadView() {
        super.loadView()

        self.view = UIView()
        self.view.backgroundColor = ThemeManager.shared.primaryDark()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imagePicker.delegate = self

        self.setupLayout()
        self.setupCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Show the status bar
        self.statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.cutoutQrView()

        // Start video capture.
        self.captureSession?.startRunning()
    }

    private func cutoutQrView() {
        // Ensures to use the current background color to set the filling color
        self.overlayView.backgroundColor?.setFill()
        UIRectFill(self.view.frame)

        let layer = CAShapeLayer()
        let path = CGMutablePath()

        // Make hole in view's overlay
        // NOTE: Here, instead of using the transparentHoleView UIView we could use a specific CFRect location...
        path.addRect(self.qrCutoutView.frame)
        path.addRect(self.overlayView.bounds)

        layer.path = path
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        self.overlayView.layer.mask = layer
    }

    private func flash(turnOff: Bool = false) {
        guard let device = self.captureDevice else { return }
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
            self.flashButton.setImage(UIImage(named: "FlashOff"), for: .normal)
        } else {
            self.flashButton.setImage(UIImage(named: "FlashOn"), for: .normal)
        }
    }
}

extension PaperWalletScanViewController {
    private func setupCamera() {
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

            self.captureSession = AVCaptureSession()

            // Set the input device on the capture session.
            self.captureSession?.addInput(input)

            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            self.captureSession?.addOutput(captureMetadataOutput)

            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreviewLayer?.frame = self.view.layer.bounds
        self.view.layer.addSublayer(self.videoPreviewLayer!)

        self.view.bringSubviewToFront(self.overlayView)
    }

    func privateKeyScanned(privateKey: String) {
        let sweepPaperWalletAmountViewController = SweepPaperWalletAmountViewController()
        let navigationController = UINavigationController(rootViewController: sweepPaperWalletAmountViewController)
        navigationController.navigationBar.updateColors()

        self.dismiss(animated: true) {
            self.present(navigationController, animated: false)
        }
    }
}

// Mark - Setup layout

extension PaperWalletScanViewController {
    private func setupLayout() {
        self.view.addSubview(self.overlayView)
        self.overlayView.addSubview(self.qrCutoutView)
        self.overlayView.addSubview(self.scanLabel)
        self.overlayView.addSubview(self.buttonsStackView)

        self.flashButton.addTarget(self, action: #selector(toggleFlash(sender:)), for: .touchUpInside)
        self.closeButton.addTarget(self, action: #selector(closeView(sender:)), for: .touchUpInside)
        self.imageButton.addTarget(self, action: #selector(openImage(sender:)), for: .touchUpInside)

        self.buttonsStackView.addArrangedSubview(flashButton)
        self.buttonsStackView.addArrangedSubview(closeButton)
        self.buttonsStackView.addArrangedSubview(imageButton)

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.overlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.overlayView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.overlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.qrCutoutView.translatesAutoresizingMaskIntoConstraints = false
        self.qrCutoutView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        self.qrCutoutView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        self.qrCutoutView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.qrCutoutView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.scanLabel.translatesAutoresizingMaskIntoConstraints = false
        self.scanLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.scanLabel.bottomAnchor.constraint(equalTo: self.qrCutoutView.topAnchor, constant: -30).isActive = true

        self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.buttonsStackView.bottomAnchor.constraint(equalTo:
            self.overlayView.layoutMarginsGuide.bottomAnchor
        ).isActive = true
        self.buttonsStackView.leadingAnchor.constraint(equalTo: self.overlayView.leadingAnchor).isActive = true
        self.buttonsStackView.trailingAnchor.constraint(equalTo: self.overlayView.trailingAnchor).isActive = true
    }

    @objc
    private func toggleFlash(sender: Any) {
        self.flash()
    }

    @objc
    private func closeView(sender: Any) {
        self.dismiss(animated: true)
    }

    @objc
    private func openImage(sender: Any) {
        self.present(self.imagePicker, animated: true)
    }
}

extension PaperWalletScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

            print(qrCode)
            self.privateKeyScanned(privateKey: qrCode)
        }

        dismiss(animated: true, completion: nil)
    }
}
