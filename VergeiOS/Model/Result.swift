//
//  Result.swift
//  VergeiOS
//
//  Created by Marvin Piekarek on 24.07.18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

public typealias ResultCallback<Value> = (Result<Value>) -> Void
