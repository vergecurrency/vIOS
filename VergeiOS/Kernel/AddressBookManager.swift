//
//  AddressBookManager.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import SwiftyJSON

class AddressBookManager {
    
    func name(byAddress address: String) -> String? {
        // TODO: For now we fetch them from an example json file.
        if let path = Bundle.main.path(forResource: "addresses", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try JSON(data: data)
                
                return json[address].string
            } catch {
                print(error)
                return nil
            }
        }
        
        return nil
    }
    
    func all() -> [Address] {
        // TODO: For now we fetch them from an example json file.
        if let path = Bundle.main.path(forResource: "addresses", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try JSON(data: data)
                var addresses: [Address] = []
                
                for (address, name) : (String, JSON) in json {
                    let item = Address()
                    item.address = address
                    item.name = name.stringValue
                    
                    addresses.append(item)
                }
                
                return addresses
            } catch {
                print(error)
                return []
            }
        }
        
        return []
    }
    
}
