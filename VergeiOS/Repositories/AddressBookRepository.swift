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
    private let dataStack: DataStack

    init(dataStack: DataStack) {
        self.dataStack = dataStack
    }

    func name(byAddress address: String) -> String? {
        guard let entity =
            ((try? self.dataStack.fetchOne(From<AddressType>().where(\.address == address)))
                as AddressType??) else {
            return nil
        }

        return entity?.name
    }

    func get(byName name: String) -> Contact? {
        guard let entity =
            ((try? self.dataStack.fetchOne(From<AddressType>().where(\.name == name)))
                as AddressType??) else {
            return nil
        }

        return transform(entity: entity)
    }

    func get(byAddress address: String) -> Contact? {
        guard let entity =
            ((try? self.dataStack.fetchOne(From<AddressType>().where(\.address == address)))
                as AddressType??) else {
            return nil
        }

        return transform(entity: entity)
    }

    func all() -> [Contact] {
        let entities = try? self.dataStack.fetchAll(From<AddressType>())
        var addresses: [Contact] = []

        for entity in entities ?? [] {
            addresses.append(transform(entity: entity))
        }

        return addresses
    }

    func put(address: Contact) {
        var entity: AddressType?
        if let existingEntity =
            ((try? self.dataStack.fetchOne(From<AddressType>().where(\.address == address.address)))
                as AddressType??) {
            entity = existingEntity
        }

        do {
            _ = try self.dataStack.perform(synchronous: { transaction -> Bool in
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
        guard let entity =
            ((try? self.dataStack.fetchOne(From<AddressType>().where(\.name == address.name)))
                as AddressType??) else {
            return
        }

        do {
            _ = try self.dataStack.perform(synchronous: { transaction -> Bool in
                transaction.delete(entity)

                return transaction.hasChanges
            })
        } catch {
            print(error.localizedDescription)
        }
    }

    func isEmpty() -> Bool {
        all().count == 0
    }

    private func transform(entity: AddressType?) -> Contact {
        var address = Contact()
        address.name = entity?.name ?? ""
        address.address = entity?.address ?? ""

        return address
    }

}
