import Foundation
import HsCryptoKit

public class HDWallet {
    private let keychain: HDKeychain

    private let purpose: UInt32
    private let coinType: UInt32

    public init(seed: Data, coinType: UInt32, xPrivKey: UInt32, purpose: Purpose = .bip44, curve: DerivationCurve = .secp256k1) {
        keychain = HDKeychain(seed: seed, xPrivKey: xPrivKey, curve: curve)
        self.purpose = purpose.rawValue
        self.coinType = coinType
    }

    public init(masterKey: HDPrivateKey1, coinType: UInt32, purpose: Purpose = .bip44, curve: DerivationCurve = .secp256k1) {
        keychain = HDKeychain(privateKey: masterKey, curve: curve)
        self.purpose = purpose.rawValue
        self.coinType = coinType
    }

    public var masterKey: HDPrivateKey1 {
        keychain.privateKey
    }

    public func privateKey(account: Int, chain: Chain) throws -> HDPrivateKey1 {
        let path = "m/\(purpose)'/\(coinType)'/\(account)'/\(chain.rawValue)"
        
        print("purpose: \(purpose)")
        print("coinType: \(coinType)")
        print("account: \(account)")
        print("chain: \(chain) (\(chain.rawValue))")
        print("path: \(path)")
        
        return try privateKey(path: path)
    }

    public func privateKey(account: Int) throws -> HDPrivateKey1 {
        try privateKey(path: "m/\(purpose)'/\(coinType)'/\(account)'")
    }

    public func privateKey(path: String) throws -> HDPrivateKey1 {
        try keychain.derivedKey(path: path)
    }

    public func publicKey(account: Int, chain: Chain) throws -> HDPublicKey {
        try privateKey(account: account).publicKey(curve: .secp256k1)
    }

    public func publicKeys(account: Int, indices: Range<UInt32>, chain: Chain) throws -> [HDPublicKey] {
        try keychain.derivedNonHardenedPublicKeys(path: "m/\(purpose)'/\(coinType)'/\(account)'/\(chain.rawValue)", indices: indices)
    }

    public enum Chain : Int {
        case external
        case `internal`
    }

}
