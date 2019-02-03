//
//  IntentViewController.swift
//  VergeSiriUI
//
//  Created by Ivan Manov on 1/31/19.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import IntentsUI

@available(iOSApplicationExtension 12.0, *)
class SiriReceiveViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    // MARK: - INUIHostedViewControlling
    
    func configureView(
        for parameters: Set<INParameter>,
        of interaction: INInteraction,
        interactiveBehavior: INUIInteractiveBehavior,
        context: INUIHostedViewContext,
        completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void
    ) {
        
        guard interaction.intent is ReceiveFundsIntent else {
            completion(false, Set(), .zero)
            return
        }
        
        WalletInfo.fetchWalletInfo { (walletInfo) in
            DispatchQueue.main.async {
                self.qrCodeImageView.image = walletInfo!.cardImage
            }
            
            completion(
                true,
                parameters,
                (walletInfo?.cardImage != nil) ?
                CGSize.init(width: 343.0, height: 240.0) :
                CGSize.zero
            )
        }
        
    }
}
