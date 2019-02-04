//
//  IpAddress.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 04/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct IpAddress: Decodable {
    
    public let ip: String
    public let country_name: String
    public let latitude: Double
    public let longitude: Double
    
}
