import Foundation
import CryptoSwift
import BitcoinKit

class Credentials {

    enum CredentialsError: Error {
        case invalidDeriver(value: String)
        case invalidWidHex(id: String)
        case derivationFailed(String)
    }

    var seed: Data
    
    init(mnemonic: [String], passphrase: String = "") {
        guard let seedData = Mnemonic.seed(mnemonic: mnemonic, passphrase: passphrase) else {
            fatalError("Failed to generate seed from mnemonic")
        }
        self.seed = seedData
    }

    func reset(mnemonic: [String], passphrase: String = "") {
        guard let seedData = Mnemonic.seed(mnemonic: mnemonic, passphrase: passphrase) else {
            print("❌ Failed to generate seed from mnemonic")
            return
        }
        self.seed = seedData
    }

    // MARK: - Master Wallet (Verge coin type 77)
    var wallet: HDWallet {
        return HDWallet(seed: seed, coinType: 77, xPrivKey: HDExtendedKeyVersion.xprv.rawValue)
    }
    
    var privateKey1: HDPrivateKey1 {
        return HDPrivateKey1(seed: seed, xPrivKey: HDExtendedKeyVersion.xprv.rawValue)
    }
    
    // MARK: - Custom Extended Public Key with "ToEA" prefix
    var customExtendedPublicKey: String? {
        do {
            let accountPrivateKey = try privateKey1
                .derived(at: 44, hardened: true)
                .derived(at: 77, hardened: true)
                .derived(at: 0, hardened: true)
            
            let pubKey = accountPrivateKey.extendedPublicKey()
            
            // Correct version bytes for "ToEA" prefix
            let toEAVersionBytes: [UInt8] = [0x02, 0x2D, 0x25, 0x33]
            
            var data = Data()
            data.append(contentsOf: toEAVersionBytes)
            data.append(pubKey.depth)
            data.append(contentsOf: withUnsafeBytes(of: pubKey.fingerprint.bigEndian) { Data($0) })
            data.append(contentsOf: withUnsafeBytes(of: pubKey.childIndex.bigEndian) { Data($0) })
            data.append(pubKey.chainCode)
            data.append(pubKey.raw)
            
            let hash = Crypto.sha256(Crypto.sha256(data))
            data.append(hash.prefix(4))
            
            let base58Encoded = Base58.encode(data)
            
            print("==> Custom Extended Public Key (ToEA format): \(base58Encoded)")
            print("==> Prefix: \(base58Encoded.hasPrefix("ToEA") ? "✅ ToEA" : "❌ \(String(base58Encoded.prefix(4)))")")
            return base58Encoded
            
        } catch {
            print("❌ Can't generate custom extended public key: \(error)")
            return nil
        }
    }
    
    // MARK: - xPubKey (Base64 format: pubkey + chaincode)
    var xPubKey: String? {
        do {
            let accountPrivateKey = try privateKey1
                .derived(at: 44, hardened: true)
                .derived(at: 77, hardened: true)
                .derived(at: 0, hardened: true)
            
            let pubKey = accountPrivateKey.extendedPublicKey()
            let publicKeyData = pubKey.raw
            let chainCode = pubKey.chainCode
            
            let combined = publicKeyData + chainCode
            
            guard combined.count == 65 else {
                print("❌ Invalid combined data length: \(combined.count)")
                return nil
            }
            
            let base64Encoded = combined.base64EncodedString()
            
            print("==> xPubKey (Base64): \(base64Encoded)")
            print("==> Length: \(combined.count) bytes")
            return base64Encoded
            
        } catch {
            print("❌ Can't generate xPubKey: \(error)")
            return nil
        }
    }
    
    // MARK: - Wallet Private Keys
    var walletPrivateKey1: HDPrivateKey1 {
        do {
            return try privateKey1.derived(at: 0, hardened: true)
        } catch {
            print("❌ Failed to derive walletPrivateKey1: \(error)")
            return privateKey1
        }
    }
    var walletPrivateKey: HDPrivateKey1 {
        return try! privateKey.derived(at: 0, hardened: true)
    }
    var privateKey: HDPrivateKey1 {
        return HDPrivateKey1(seed: seed, xPrivKey: HDExtendedKeyVersion.xprv.rawValue)
    }
//    var walletPrivateKey: HDPrivateKey1 {
//        return walletPrivateKey1
//    }

    // MARK: - BIP44 account-level key (m/44'/77'/0')
    var bip44PrivateKey: HDPrivateKey1 {
        do {
            return try privateKey1
                .derived(at: 44, hardened: true)
                .derived(at: 77, hardened: true)
                .derived(at: 0, hardened: true)
        } catch {
            print("❌ Failed to derive BIP44 private key: \(error)")
            return privateKey1
        }
    }
    
    var publicKey: HDPublicKey {
        return bip44PrivateKey.extendedPublicKey()
    }
    
    // MARK: - Request key (m/1'/0)
    var requestPrivateKey: HDPrivateKey1 {
        do {
            return try privateKey1
                .derived(at: 1, hardened: true)
                .derived(at: 0, hardened: false)
        } catch {
            print("❌ Failed to derive requestPrivateKey: \(error)")
            return privateKey1
        }
    }
    
    // MARK: - Request Public Key
    var requestPubKey: String? {
        let requestPriv = requestPrivateKey
        let pubKey = requestPriv.publicKey(compressed: true)
        let hex = pubKey.raw.toHexString()
        
        guard hex.count == 66 else {
            print("❌ Invalid public key length: \(hex.count)")
            return nil
        }
        
        print("✅ Request PubKey (m/1'/0): \(hex)")
        return hex
    }

    // MARK: - Account Extended Public Key
    var accountExtendedPublicKey: String? {
        do {
            let accountKey = try wallet.publicKey(account: 0, chain: .external)
            let extendedPubKey = accountKey.extended().description
            print("==> Account Extended Public Key: \(extendedPubKey)")
            return extendedPubKey
        } catch {
            print("❌ Can't get account extended public key: \(error)")
            return nil
        }
    }
    
    // MARK: - BIP32 Extended Public Key
    var bip32ExtenedPublicKey: String? {
        do {
            let accountPrivateKey = try wallet.privateKey(account: 0, chain: .external)
            let publicKey = accountPrivateKey.publicKey(curve: .secp256k1)
            let accountXpub = publicKey.extended().description
            
            print("==> BIP32 Extended Public Key: \(accountXpub)")
            return accountXpub
        } catch {
            print("❌ Can't get BIP32 extended public key: \(error)")
            return nil
        }
    }
    
    // MARK: - BIP32 Extended Private Key
    var bip32extendedPrivateKey: String? {
        do {
            let vergePrivateKey = try wallet.privateKey(account: 0, chain: .external)
            let extendedPrivKey = vergePrivateKey.extended().description
            print("==> BIP32 Extended Private Key: \(extendedPrivKey)")
            return extendedPrivKey
        } catch {
            print("❌ Can't get BIP32 extended private key: \(error)")
            return nil
        }
    }
    
    // MARK: - Account Extended Private Key
    var accountExtendedPrivateKey: String? {
        do {
            let vergePrivateKey = try wallet.privateKey(account: 0)
            let extendedPrivKey = vergePrivateKey.extended().description
            print("==> Account Extended Private Key: \(extendedPrivKey)")
            return extendedPrivKey
        } catch {
            print("❌ Can't get account extended private key: \(error)")
            return nil
        }
    }
    
    // MARK: - Shared Encrypting Key
    var sharedEncryptingKey: String {
        let privateKeyData = walletPrivateKey1.privateKey().data
        let sha256Data = Crypto.sha256(privateKeyData)
        return sha256Data[0..<16].base64EncodedString()
    }

    // MARK: - Personal Encrypting Key
    var personalEncryptingKey: String {
        do {
            let data = Crypto.sha256(requestPrivateKey.raw)
            let key = "personalKey".data(using: .utf8)!
            let hmac = try HMAC(key: key.bytes, variant: .sha2(.sha256)).authenticate(data.bytes)
            return Data(hmac[0..<16]).base64EncodedString()
        } catch {
            print("❌ Failed to derive personalEncryptingKey: \(error)")
            return ""
        }
    }

    // MARK: - Derive Private Key by Path
    func privateKeyBy(path: String, privateKey: HDPrivateKey1) throws -> PrivateKey {
        var key = privateKey
        let pathComponents = path.replacingOccurrences(of: "m/", with: "").split(separator: "/")
        
        for deriver in pathComponents {
            let isHardened = deriver.hasSuffix("'")
            let deriverString = isHardened ? String(deriver.dropLast()) : String(deriver)
            
            guard let deriverInt32 = UInt32(deriverString) else {
                throw CredentialsError.invalidDeriver(value: String(deriver))
            }

            key = try key.derived(at: deriverInt32, hardened: isHardened)
        }

        return key.privateKey()
    }

    // MARK: - Build Secret String
    func buildSecret(walletId: String) throws -> String {
        let cleanWalletId = walletId.replacingOccurrences(of: "-", with: "")
        
        guard let widHex = Data(hex: cleanWalletId) else {
            throw CredentialsError.invalidWidHex(id: walletId)
        }

        let widBase58 = Base58.encode(widHex)
        let paddedWid = String(repeating: "0", count: max(0, 22 - widBase58.count)) + widBase58
        let wif = privateKey1.privateKey().toWIF()

        return "\(paddedWid)\(wif)Lxvg"
    }
    
    // MARK: - Helper: Decode xPubKey
    func decodeXPubKey(_ base64String: String) -> (publicKey: Data, chainCode: Data)? {
        guard let decoded = Data(base64Encoded: base64String),
              decoded.count == 65 else {
            print("❌ Invalid xPubKey format")
            return nil
        }
        
        let publicKey = decoded[0..<33]
        let chainCode = decoded[33..<65]
        
        return (Data(publicKey), Data(chainCode))
    }
    
    // MARK: - Helper: Decode ToEA Key
    func decodeToEAKey(_ toEAKey: String) {
        guard let decoded = Base58.decode(toEAKey) else {
            print("❌ Failed to decode Base58")
            return
        }
        
        print("========== DECODING ToEA KEY ==========")
        print("Total decoded length: \(decoded.count) bytes")
        
        let versionBytes = decoded[0..<4]
        let depth = decoded[4]
        let fingerprint = decoded[5..<9]
        let childIndex = decoded[9..<13]
        let chainCode = decoded[13..<45]
        let publicKey = decoded[45..<78]
        let checksum = decoded[78..<82]
        
        print("Version bytes: \(versionBytes.map { String(format: "0x%02X", $0) }.joined(separator: ", "))")
        print("Depth: \(depth)")
        print("Fingerprint: \(fingerprint.toHexString())")
        print("Child Index: \(childIndex.toHexString())")
        print("Chain Code: \(chainCode.toHexString())")
        print("Public Key: \(publicKey.toHexString())")
        print("Checksum: \(checksum.toHexString())")
        
        let payload = decoded[0..<78]
        let computedHash = Crypto.sha256(Crypto.sha256(payload))
        let computedChecksum = computedHash.prefix(4)
        
        print("Checksum valid: \(checksum == computedChecksum)")
        print("========================================")
    }
}

// MARK: - Usage Example
extension Credentials {
    func printAllKeys() {
        print("========== VERGE WALLET KEYS ==========")
        
        if let customPub = customExtendedPublicKey {
            print("✅ Custom Extended Public Key (ToEA format):")
            print(customPub)
        }
        
        if let xPub = xPubKey {
            print("✅ xPubKey (Base64):")
            print(xPub)
            
            if let decoded = decodeXPubKey(xPub) {
                print("Decoded Components:")
                print("Public Key (33 bytes): \(decoded.publicKey.toHexString())")
                print("Chain Code (32 bytes): \(decoded.chainCode.toHexString())")
            }
        }
        
        if let reqPub = requestPubKey {
            print("✅ Request PubKey (m/1'/0):")
            print(reqPub)
        }
        
        print("✅ Shared Encrypting Key:")
        print(sharedEncryptingKey)
        
        print("✅ Personal Encrypting Key:")
        print(personalEncryptingKey)
        
        print("=======================================")
    }
}
