//
//  BlockchainInfo.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 24.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

/*{
    "info": {
        "version": 120100,
        "protocolversion": 70012,
        "blocks": 688,
        "timeoffset": 0,
        "connections": 5,
        "proxy": "",
        "difficulty": 1,
        "testnet": false,
        "relayfee": 0.00001,
        "errors": "",
        "network": "livenet"
    }
}*/


public struct BlockchainInfo: Decodable {
    public let info: Info?
}

public struct Info : Decodable {
    public let version: Int?
    public let protocolversion: Int?
    public let blocks: Int?
    public let timeoffset: Int?
    public let connections: Int?
    public let proxy: String?
    public let difficulty: Float?
    public let testnet: Bool?
    public let relayfee: Float?
    public let network: String?
}
