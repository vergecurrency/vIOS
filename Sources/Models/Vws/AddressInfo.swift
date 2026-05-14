//
// Created by Swen van Zanten on 09/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct AddressInfo: Decodable {
        let network: String
        let path: String
        let isChange: Bool
        let coin: String
        let _id: String?
        let type: String
        let createdOn: Int
        let version: String
        let publicKeys: [String]
        let address: String
        let walletId: String
        let hasActivity: Bool?

        enum CodingKeys: String, CodingKey {
            case network
            case path
            case isChange
            case coin
            case _id
            case type
            case createdOn
            case version
            case publicKeys
            case address
            case walletId
            case hasActivity
        }

        init(
            network: String,
            path: String,
            isChange: Bool,
            coin: String,
            _id: String?,
            type: String,
            createdOn: Int,
            version: String,
            publicKeys: [String],
            address: String,
            walletId: String,
            hasActivity: Bool?
        ) {
            self.network = network
            self.path = path
            self.isChange = isChange
            self.coin = coin
            self._id = _id
            self.type = type
            self.createdOn = createdOn
            self.version = version
            self.publicKeys = publicKeys
            self.address = address
            self.walletId = walletId
            self.hasActivity = hasActivity
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            network = try container.decodeIfPresent(String.self, forKey: .network) ?? ""
            path = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
            isChange = try container.decodeIfPresent(Bool.self, forKey: .isChange) ?? false
            coin = try container.decodeIfPresent(String.self, forKey: .coin) ?? "xvg"
            _id = try container.decodeIfPresent(String.self, forKey: ._id)
            type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
            createdOn = try container.decodeFlexibleIntIfPresent(forKey: .createdOn) ?? 0
            version = try container.decodeFlexibleStringIfPresent(forKey: .version) ?? ""
            publicKeys = try container.decodeIfPresent([String].self, forKey: .publicKeys) ?? []
            address = try container.decode(String.self, forKey: .address)
            walletId = try container.decodeIfPresent(String.self, forKey: .walletId) ?? ""
            hasActivity = try container.decodeIfPresent(Bool.self, forKey: .hasActivity)
        }

        public var createdOnDate: Date {
            return Date(timeIntervalSince1970: TimeInterval(self.createdOn))
        }
    }

    struct AddressWrappedResponse: Decodable {
        let address: AddressInfo
    }

    struct AddressResponse: Decodable {
           let addresses: [AddressInfo]
       }
    struct APIErrorResponse: Decodable {
        let code: String
        let message: String
    }
    struct ErrorResponse: Decodable {
        let code: String
        let message: String
    }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleIntIfPresent(forKey key: Key) throws -> Int? {
        if let intValue = try decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }

        if let doubleValue = try decodeIfPresent(Double.self, forKey: key) {
            return Int(doubleValue)
        }

        if let stringValue = try decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        }

        return nil
    }

    func decodeFlexibleStringIfPresent(forKey key: Key) throws -> String? {
        if let stringValue = try decodeIfPresent(String.self, forKey: key) {
            return stringValue
        }

        if let intValue = try decodeIfPresent(Int.self, forKey: key) {
            return String(intValue)
        }

        if let doubleValue = try decodeIfPresent(Double.self, forKey: key) {
            return String(doubleValue)
        }

        return nil
    }
}
