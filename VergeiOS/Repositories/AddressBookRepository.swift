//
//  AddressBookRepository.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import CoreStore

class AddressBookRepository {
    
    func name(byAddress address: String) -> String? {
        guard let entity = try? CoreStore.fetchOne(From<AddressType>().where(\.address == address)) else {
            return nil
        }

        return entity?.name
    }

    func get(byName name: String) -> Contact? {
        guard let entity = try? CoreStore.fetchOne(From<AddressType>().where(\.name == name)) else {
            return nil
        }

        return transform(entity: entity)
    }

    func get(byAddress address: String) -> Contact? {
        guard let entity = try? CoreStore.fetchOne(From<AddressType>().where(\.address == address)) else {
            return nil
        }

        return transform(entity: entity)
    }
    
    func all() -> [Contact] {
        let entities = try? CoreStore.fetchAll(From<AddressType>())
        var addresses: [Contact] = []

        for entity in entities ?? [] {
            addresses.append(transform(entity: entity))
        }
        
        return addresses
    }

    func put(address: Contact) {
        var entity: AddressType? = nil
        if let existingEntity = try? CoreStore.fetchOne(From<AddressType>().where(\.address == address.address)) {
            entity = existingEntity
        }
        
        do {
            let _ = try CoreStore.perform(synchronous: { transaction -> Bool in
                if entity == nil {
                    entity = transaction.create(Into<AddressType>())
                } else {
                    entity = transaction.edit(entity)
                }

                entity?.name = address.name
                entity?.address = address.address

                return transaction.hasChanges
            })
        } catch {
            print(error.localizedDescription)
        }
    }

    func remove(address: Contact) {
        guard let entity = try? CoreStore.fetchOne(From<AddressType>().where(\.name == address.name)) else {
            return
        }

        do {
            let _ = try CoreStore.perform(synchronous: { transaction -> Bool in
                transaction.delete(entity)

                return transaction.hasChanges
            })
        } catch {
            print(error.localizedDescription)
        }
    }

    func isEmpty() -> Bool {
        return all().count == 0
    }

    private func transform(entity: AddressType?) -> Contact {
        var address = Contact()
        address.name = entity?.name ?? ""
        address.address = entity?.address ?? ""

        return address
    }

}
