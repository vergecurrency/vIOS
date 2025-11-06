import Foundation
import HsCryptoKit

public class HDAccountWallet {
    private let keychain: HDKeychain

    public var gapLimit: Int

    public init(privateKey: HDPrivateKey1, curve: DerivationCurve = .secp256k1, gapLimit: Int = 5) {
        self.gapLimit = gapLimit

        keychain = HDKeychain(privateKey: privateKey, curve: curve)
    }

    public func privateKey(index: Int, chain: Chain) throws -> HDPrivateKey1 {
        switch keychain.curve {
        case .secp256k1: return try privateKey(path: "\(chain.rawValue)/\(index)")
        case .ed25519: throw DerivationError.cantDeriveNonHardened
        }
    }

    public func privateKey(path: String) throws -> HDPrivateKey1 {
        try keychain.derivedKey(path: path)
    }

    public func publicKey(index: Int, chain: Chain) throws -> HDPublicKey {
        switch keychain.curve {
        case .secp256k1: return try privateKey(index: index, chain: chain).publicKey(curve: .secp256k1)
        case .ed25519: throw DerivationError.cantDeriveNonHardened
        }
    }

    public func publicKeys(indices: Range<UInt32>, chain: Chain) throws -> [HDPublicKey] {
        switch keychain.curve {
        case .secp256k1: return try keychain.derivedNonHardenedPublicKeys(path: "\(chain.rawValue)", indices: indices)
        case .ed25519: throw DerivationError.cantDeriveNonHardened
        }
    }

    public enum Chain : Int {
        case external
        case `internal`
    }

}
