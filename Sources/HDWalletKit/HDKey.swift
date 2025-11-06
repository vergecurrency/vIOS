import Foundation
import BitcoinKit
import BitcoinKitPrivate
import HsCryptoKit
#if BitcoinKitXcode
import BitcoinKit.Private
#else
import BitcoinKitPrivate
#endif
public class HDKey {
    public let version: UInt32
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32
    public let network: Network
    let _raw: Data
    public let chainCode: Data

    open var raw: Data { _raw }

    public init(raw: Data, chainCode: Data,network: Network = .mainnetXVG, version: UInt32, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.network = network
        self.version = version
        _raw = raw
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }
//    public func extended() -> String {
//        var data = Data()
//        data += network.xpubkey.bigEndian
//        data += depth.littleEndian
//        data += fingerprint.littleEndian
//        data += childIndex.littleEndian
//        data += chainCode
//        data += raw
//        return Base58Check.encode(data)
//    }
    
    public func extended() -> String {
        var data = Data()
        
        var version = network.xpubkey.bigEndian
        var depth = self.depth
        var fingerprint = self.fingerprint.bigEndian
        var childIndex = self.childIndex.bigEndian

        // append version (UInt32)
        withUnsafeBytes(of: &version) { data.append(contentsOf: $0) }

        // append depth (UInt8)
        withUnsafeBytes(of: &depth) { data.append(contentsOf: $0) }

        // append fingerprint (UInt32)
        withUnsafeBytes(of: &fingerprint) { data.append(contentsOf: $0) }

        // append childIndex (UInt32)
        withUnsafeBytes(of: &childIndex) { data.append(contentsOf: $0) }

        data.append(chainCode)  // Data OK
        data.append(raw)        // Data OK

        return Base58Check.encode(data)
    }

    public func publicKey() -> PublicKey {
        return PublicKey(bytes: raw, network: .mainnetXVG)
   }
    public init(extendedKey: Data) throws {
        try HDExtendedKey.isValid(extendedKey)
        version = extendedKey.prefix(4).hs.to(type: UInt32.self).bigEndian
        network = .mainnetXVG
        depth = extendedKey[4]
        fingerprint = extendedKey[5..<9].hs.to(type: UInt32.self).bigEndian
        childIndex = extendedKey[9..<12].hs.to(type: UInt32.self).bigEndian
        chainCode = extendedKey[13..<45]
        _raw = extendedKey[45..<78]
    }

}

extension HDKey {
    private func computePublicKeyData() -> Data {
        return _SwiftKey.computePublicKey(fromPrivateKey: raw, compression: true)!
    }
    public func extendedPublicKey() -> HDPublicKey {
        return HDPublicKey(raw: computePublicKeyData(), chainCode: chainCode, version: 0x0488b21e, depth: depth, fingerprint: fingerprint, childIndex: childIndex)
    }

    func data(version: UInt32? = nil) -> Data {
        var data = Data()
        data += (version ?? self.version).bigEndian.data
        data += Data([depth])
        data += fingerprint.bigEndian.data
        data += childIndex.bigEndian.data
        data += chainCode
        data += _raw
        let checksum = Crypto.doubleSha256(data).prefix(4)
        return data + checksum
    }

}

public extension HDKey {

//    func extended(customVersion: HDExtendedKeyVersion? = nil) -> String {
//        let version = customVersion?.rawValue ??  version
//        return Base58.encode(data(version: version))
//    }
//    
    

    var description: String {
        "\(raw.hs.hex) ::: \(chainCode.hs.hex) ::: depth: \(depth) - fingerprint: \(fingerprint) - childIndex: \(childIndex)"
    }

}
