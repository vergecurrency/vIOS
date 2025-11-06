import Crypto
import BitcoinKit
import CryptoKit
import Foundation
import HsCryptoKit
import HsExtensions
import secp256k1

public class HDPrivateKey1: HDKey {
    override public var raw: Data {
        _raw.suffix(32) // first byte is 0x00
    }

    var extendedVersion: HDExtendedKeyVersion {
        HDExtendedKeyVersion(rawValue: version) ?? .xprv // created key successfully validated before creation, so fallback not using
    }
    public func privateKey() -> PrivateKey {
        return PrivateKey(data: raw, network: .mainnetXVG, isPublicKeyCompressed: true)
    }

    override public init(raw: Data, chainCode: Data, network: Network, version: UInt32, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        super.init(
            raw: raw,
            chainCode: chainCode,
            version: version,
            depth: depth,
            fingerprint: fingerprint,
            childIndex: childIndex
        )
    }

    override init(extendedKey: Data) throws {
        try super.init(extendedKey: extendedKey)
    }

    public init(privateKey: Data, chainCode: Data, version: UInt32, depth: UInt8 = 0, fingerprint: UInt32 = 0, childIndex: UInt32 = 0) {
        let zeros = privateKey.count < 33 ? [UInt8](repeating: 0, count: 33 - privateKey.count) : []

        super.init(
            raw: Data(zeros) + privateKey,
            chainCode: chainCode,
            version: version,
            depth: depth,
            fingerprint: fingerprint,
            childIndex: childIndex
        )
    }

    public convenience init(seed: Data, xPrivKey: UInt32, salt: Data = DerivationCurve.secp256k1.bip32SeedSalt) {
        let hmac = Crypto.hmacSha512(seed, key: salt)
        let privateKey = hmac[0 ..< 32]
        let chainCode = hmac[32 ..< 64]
        self.init(privateKey: privateKey, chainCode: chainCode, version: xPrivKey)
    }
}

public extension HDPrivateKey1 {
    func derived(at index: UInt32, hardened: Bool, curve: DerivationCurve = .secp256k1) throws -> HDPrivateKey1 {
        let edge: UInt32 = 0x8000_0000
        guard (edge & index) == 0 else {
            throw DerivationError.invalidChildIndex
        }

        if !(curve.supportNonHardened || hardened) {
            throw DerivationError.cantDeriveNonHardened
        }

        var data = Data()
        let publicKey = curve.publicKey(privateKey: raw, compressed: true)
        if hardened {
            data += Data([0])
            data += raw
        } else {
            data += publicKey
        }

        let derivingIndex = CFSwapInt32BigToHost(hardened ? (edge | index) : index)
        data += derivingIndex.data

        let digest = Crypto.hmacSha512(data, key: chainCode)

        let derivedPrivateKey = try curve.applyParameters(parentPrivateKey: raw, childKey: digest[0 ..< 32])
        let derivedChainCode = digest[32 ..< 64]

        let hash = Crypto.ripeMd160Sha256(publicKey)
        let fingerprint: UInt32 = hash[0 ..< 4].hs.to(type: UInt32.self)

        return HDPrivateKey1(
            privateKey: derivedPrivateKey,
            chainCode: derivedChainCode,
            version: version,
            depth: depth + 1,
            fingerprint: fingerprint.bigEndian,
            childIndex: derivingIndex.bigEndian
        )
    }

    func publicKey(compressed: Bool = true, curve: DerivationCurve = .secp256k1) -> HDPublicKey {
        HDPublicKey(raw: Crypto.publicKey(privateKey: raw, curve: curve, compressed: compressed),
                    chainCode: chainCode,
                    version: extendedVersion.pubKey.rawValue,
                    depth: depth,
                    fingerprint: fingerprint,
                    childIndex: childIndex)
    }

    func derivedNonHardenedPublicKeys(at indices: Range<UInt32>) throws -> [HDPublicKey] {
        guard let firstIndex = indices.first, let lastIndex = indices.last else {
            return []
        }

        if (0x8000_0000 & firstIndex) != 0, (0x8000_0000 & lastIndex) != 0 {
            throw DerivationError.invalidChildIndex
        }

        let hdPubKey = publicKey(curve: .secp256k1)
        var keys = [HDPublicKey]()

        try indices.forEach { int32 in
            try keys.append(hdPubKey.derived(at: int32))
        }

        return keys
    }
}

public enum DerivationError: Error {
    case derivationFailed
    case cantDeriveNonHardened
    case invalidChildIndex
    case invalidPath
    case invalidHmacToPoint
    case invalidRawToPoint
    case invalidCombinePoints
}
