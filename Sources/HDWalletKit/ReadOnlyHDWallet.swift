import Foundation
import HsCryptoKit

public class ReadOnlyHDWallet {

    enum ParseError: Error {
        case InvalidExtendedPublicKey
        case InvalidChecksum
    }

    private static func dataTo<T>(data: Data, type: T.Type) -> T {
        data.withUnsafeBytes { $0.load(as: T.self) }
    }

    public static func publicKeys(hdPublicKey: HDPublicKey, indices: Range<UInt32>, chain: HDWallet.Chain, curve: DerivationCurve = .secp256k1) throws -> [HDPublicKey] {
        guard let firstIndex = indices.first, let lastIndex = indices.last else {
            return []
        }

        if (0x80000000 & firstIndex) != 0 && (0x80000000 & lastIndex) != 0 {
            throw DerivationError.invalidChildIndex
        }

        let derivedHdKey = try hdPublicKey.derived(at: UInt32(chain.rawValue))

        var keys = [HDPublicKey]()
        for i in indices {
            keys.append(try derivedHdKey.derived(at: i))
        }

        return keys
    }

    public static func publicKeys(extendedPublicKey: String, indices: Range<UInt32>, chain: HDWallet.Chain, curve: DerivationCurve = .secp256k1) throws -> [HDPublicKey] {
        let data = Base58.decode(extendedPublicKey)

        guard data.count == 82 else {
            throw ParseError.InvalidExtendedPublicKey
        }

        let xPubKey = dataTo(data: Data(data[0..<4].reversed()), type: UInt32.self)
        let depth = dataTo(data: Data(data[4..<5]), type: UInt8.self)
        let fingerprint = dataTo(data: Data(data[5..<9]), type: UInt32.self)
        let childIndex = dataTo(data: Data(data[9..<13]), type: UInt32.self)
        let chainCode = Data(data[13..<45])
        let key = Data(data[45..<78])
        let checksum = Data(data[78..<82])

        guard checksum == Crypto.doubleSha256(data.prefix(78)).prefix(4) else {
            throw ParseError.InvalidChecksum
        }

        let hdPublicKey = HDPublicKey(raw: key, chainCode: chainCode, version: xPubKey, depth: depth, fingerprint: fingerprint, childIndex: childIndex)

        return try Self.publicKeys(hdPublicKey: hdPublicKey, indices: indices, chain: chain)
    }

}
