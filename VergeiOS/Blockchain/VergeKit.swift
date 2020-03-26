//
//  VergeKit.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

extension Network {
    static let mainnetXVG: Network = XVGMainnet()

    fileprivate static var _myComputedProperty = [String:UInt8]()

    /// If present, always 0001, and indicates the presence of witness data
    /// public let flag: UInt16 // If present, always 0001, and indicates the presence of witness data
    /// Transaction timestamp
    var stealthVersion: UInt8 {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(Network.self, to: Int.self))
            return Network._myComputedProperty[tmpAddress] ?? 0
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(Network.self, to: Int.self))
            Network._myComputedProperty[tmpAddress] = newValue
        }
    }
}

class XVGMainnet: Network {
    init() {
        let tmpAddress = String(format: "%p", unsafeBitCast(Network.self, to: Int.self))
        Network._myComputedProperty[tmpAddress] = 0x28
    }

    override var scheme: String {
        "verge"
    }

    override var magic: UInt32 {
        0xf7a77eff
    }

    override var dnsSeeds: [String] {
        [
            "159.89.202.56",
            "138.197.68.130",
            "165.227.31.52",
            "159.89.202.56",
            "188.40.78.31",
            "176.9.143.143",
            "198.27.82.41"
        ]
    }

    override var name: String {
        "livenet"
    }

    override var alias: String {
        "mainnet"
    }
    override var pubkeyhash: UInt8 {
        0x1e
    }

    override var privatekey: UInt8 {
        0x9e
    }

    override var scripthash: UInt8 {
        0x21
    }

    override var xpubkey: UInt32 {
        0x022d2533
    }
    override var xprivkey: UInt32 {
        0x0221312b
    }

    override var port: UInt32 {
        21_102
    }

    override var checkpoints: [Checkpoint] {
        []
    }

    // These hashes are genesis blocks' ones
    override var genesisBlock: Data {
        Data(Data(hex: "00000fc63692467faeb20cdb3b53200dc601d75bdfa1001463304cc790d77278")!.reversed())
    }
}

extension Transaction  {
    private static var _myComputedProperty = [String:UInt32]()

    /// If present, always 0001, and indicates the presence of witness data
    /// public let flag: UInt16 // If present, always 0001, and indicates the presence of witness data
    /// Transaction timestamp
    var timestamp: UInt32? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return Transaction._myComputedProperty[tmpAddress] ?? nil
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            Transaction._myComputedProperty[tmpAddress] = newValue
        }
    }

    init(
        version: UInt32,
        timestamp: UInt32?,
        inputs: [TransactionInput],
        outputs: [TransactionOutput],
        lockTime: UInt32
    ) {
        self.init(version: version, inputs: inputs, outputs: outputs, lockTime: lockTime)

        self.timestamp = timestamp
    }

    public func serialized() -> Data {
        var data = Data()
        data += version
        if let timestamp = timestamp {
            data += timestamp
        }
        data += txInCount.serialized()
        data += inputs.flatMap { $0.serialized() }
        data += txOutCount.serialized()
        data += outputs.flatMap { $0.serialized() }
        data += lockTime

        return data
    }
}

extension BitcoinAddress {
    init(verge: String) {
        
    }
}

struct StealthAddress: Address {
    enum HashType: UInt8 {
        case stealthHash = 16
    }

    var legacy: String

    var network: Network
    var type: StealthAddress.HashType
    var hashType: BitcoinAddress.HashType
    var data: Data
    var publicKey: Data?
    var cashaddr: String = ""

    let scanPublicKey: Data
    let spendPublicKey: Data

    init(scanPublicKey: PublicKey, spendPublicKey: PublicKey, network: Network) {
        var addressData = Data()
        // Version
        addressData.append(network.stealthVersion)
        // Options
        addressData.append(0)
        // Scan key
        addressData.append(scanPublicKey.data)
        // Number of scan keys
        addressData.append(1)
        // Spend key
        addressData.append(spendPublicKey.data)
        // Number of sign keys
        addressData.append(1)
        // Prefix length
        addressData.append(0)

        self.network = network
        self.type = StealthAddress.HashType.stealthHash
        self.hashType = BitcoinAddress.HashType.pubkeyHash
        self.data = addressData
        self.legacy = Base58Check.encode(addressData)

        self.scanPublicKey = scanPublicKey.data
        self.spendPublicKey = spendPublicKey.data
    }

    init(_ legacy: String) throws {
        guard let raw = Base58Check.decode(legacy) else {
            throw AddressError.invalid
        }

        let checksum = raw.suffix(4)
        let stealthHash = raw.dropLast(4)
        let checksumConfirm = Crypto.sha256sha256(stealthHash).prefix(4)
        guard checksum == checksumConfirm else {
            throw AddressError.invalid
        }

        let network: Network
        let type: StealthAddress.HashType
        let addressPrefix = stealthHash[0]
        switch addressPrefix {
        case Network.mainnetXVG.stealthVersion:
            network = .mainnetXVG
            type = .stealthHash
        default:
            throw AddressError.invalidVersionByte
        }

        self.scanPublicKey = stealthHash.dropFirst(2).dropLast(36)
        self.spendPublicKey = stealthHash.dropFirst(36).dropLast(2)

        self.network = network
        self.type = type
        self.hashType = BitcoinAddress.HashType.pubkeyHash
        self.publicKey = nil
        self.data = stealthHash
        self.legacy = legacy
    }

}

extension StealthAddress: CustomStringConvertible {
    var description: String {
        legacy
    }
}

class ByteStream {
    let data: Data
    private var offset = 0

    var availableBytes: Int {
        data.count - offset
    }

    init(_ data: Data) {
        self.data = data
    }

    func read<T>(_ type: T.Type) -> T {
        let size = MemoryLayout<T>.size
        let value = data[offset..<(offset + size)].to(type: type)
        offset += size
        return value
    }

    func read(_ type: VarInt.Type) -> VarInt {
        let len = data[offset..<(offset + 1)].to(type: UInt8.self)
        let length: UInt64
        switch len {
        case 0...252:
            length = UInt64(len)
            offset += 1
        case 0xfd:
            offset += 1
            length = UInt64(data[offset..<(offset + 2)].to(type: UInt16.self))
            offset += 2
        case 0xfe:
            offset += 1
            length = UInt64(data[offset..<(offset + 4)].to(type: UInt32.self))
            offset += 4
        case 0xff:
            offset += 1
            length = UInt64(data[offset..<(offset + 8)].to(type: UInt64.self))
            offset += 8
        default:
            offset += 1
            length = UInt64(data[offset..<(offset + 8)].to(type: UInt64.self))
            offset += 8
        }
        return VarInt(length)
    }

    func read(_ type: VarString.Type) -> VarString {
        let length = read(VarInt.self).underlyingValue
        let size = Int(length)
        let value = data[offset..<(offset + size)].to(type: String.self)
        offset += size
        return VarString(value)
    }

    func read(_ type: Data.Type, count: Int) -> Data {
        let value = data[offset..<(offset + count)]
        offset += count
        return Data(value)
    }
}

extension UInt32: BinaryConvertible {}

protocol BinaryConvertible {
    static func +(lhs: Data, rhs: Self) -> Data
    static func +=(lhs: inout Data, rhs: Self)
}

extension BinaryConvertible {
    static func +(lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return lhs + data
    }

    static func +=(lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension Data: BinaryConvertible {
    static func +(lhs: Data, rhs: Data) -> Data {
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        return data
    }
}

extension Data {
    func to<T>(type: T.Type) -> T {
        var data = Data(count: MemoryLayout<T>.size)
        // Doing this for aligning memory layout
        _ = data.withUnsafeMutableBytes { self.copyBytes(to: $0) }
        return data.withUnsafeBytes { $0.load(as: T.self) }
    }

    func to(type: String.Type) -> String {
        String(bytes: self, encoding: .ascii)!.replacingOccurrences(of: "\0", with: "")
    }

    func to(type: VarInt.Type) -> VarInt {
        let value: UInt64
        let length = self[0..<1].to(type: UInt8.self)
        switch length {
        case 0...252:
            value = UInt64(length)
        case 0xfd:
            value = UInt64(self[1...2].to(type: UInt16.self))
        case 0xfe:
            value = UInt64(self[1...4].to(type: UInt32.self))
        case 0xff:
            value = self[1...8].to(type: UInt64.self)
        default:
            fatalError("This switch statement should be exhaustive without default clause")
        }
        return VarInt(value)
    }
}
