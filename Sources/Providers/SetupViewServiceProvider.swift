//
// Created by Swen van Zanten on 2019-04-10.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class SetupViewServiceProvider: ServiceProvider {

    override func register() {
        container.storyboardInitCompleted (WelcomeViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.transactionManager = r.resolve(TransactionManager.self)
        }

        container.storyboardInitCompleted (PassphraseConfirmationViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (FinishSetupViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.credentials = r.resolve(Credentials.self)
            c.walletManager = r.resolve(WalletManagerProtocol.self)
            c.log = r.resolve(Logger.self)
        }

        container.storyboardInitCompleted (PaperkeyShowViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (ConfirmPaperkeyViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.log = r.resolve(Logger.self)
        }

        container.storyboardInitCompleted (ConfirmPinViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (PinUnlockViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (PaperKeyWordsViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }

        container.storyboardInitCompleted (FinalRecoveryController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
        }
    }

}
