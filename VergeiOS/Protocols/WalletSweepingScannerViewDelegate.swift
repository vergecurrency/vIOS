//
//  WalletSweepingScannerViewDelegate.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07/08/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

protocol WalletSweepingScannerViewDelegate: class {
    func didScanValue(scannedValue: String)
}
