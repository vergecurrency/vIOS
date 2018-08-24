//
// Created by Swen van Zanten on 24-08-18.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

protocol RecipientDelegate {
    func didSelectRecipientAddress(_ address: String)
    func selectedRecipientAddress() -> String
}
