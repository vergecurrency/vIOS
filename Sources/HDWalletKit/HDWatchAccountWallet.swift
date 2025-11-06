import Foundation

public class HDWatchAccountWallet {
    private let publicKey: HDPublicKey

    public init(publicKey: HDPublicKey) {
        self.publicKey = publicKey
    }


    public func publicKey(index: Int, chain: Chain) throws -> HDPublicKey {
        try publicKey.derived(at: UInt32(chain.rawValue)).derived(at: UInt32(index))
    }

    public func publicKeys(indices: Range<UInt32>, chain: Chain) throws -> [HDPublicKey] {
        guard let firstIndex = indices.first, let lastIndex = indices.last else {
            return []
        }

        if (0x80000000 & firstIndex) != 0 && (0x80000000 & lastIndex) != 0 {
            throw DerivationError.invalidChildIndex
        }

        let derivedHdKey = try publicKey.derived(at: UInt32(chain.rawValue))

        var keys = [HDPublicKey]()
        for i in indices {
            keys.append(try derivedHdKey.derived(at: i))
        }

        return keys
    }

    public enum Chain : Int {
        case external
        case `internal`
    }

}
