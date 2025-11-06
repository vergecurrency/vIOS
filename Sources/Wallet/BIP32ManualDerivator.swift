//
//  BIP32ManualDerivator.swift
//  VergeiOS
//
//  Created by shami kapoor on 03/10/25.
//  Copyright © 2025 Verge Currency. All rights reserved.
//

import Foundation
import CommonCrypto
import BigInt // Make sure you've added this package
import BitcoinKit
import CryptoKit

// MARK: - Public Derivator

/// A tool for performing manual BIP32 key derivation.
/// This correctly implements the logic from BIP32 to derive child keys from a parent key.
public enum BIP32ManualDerivator {
    
    /// The order of the secp256k1 elliptic curve.
    private static let curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
    
    /// Custom errors for the derivation process.
    public enum DerivationError: Error {
        case invalidPath
        case derivationFailed
        case invalidPrivateKey
    }
    
    /**
     Derives a child key and chain code from a master key and a BIP44 path.
     
     - Parameters:
     - masterPrivateKey: The 32-byte master private key.
     - chainCode: The 32-byte master chain code.
     - path: The derivation path string (e.g., "m/44'/77'/0'/0/0").
     - Returns: A tuple containing the final derived private key and chain code.
     - Throws: `DerivationError` if the path is invalid or derivation fails at any step.
     */
    public static func deriveBip32(
        masterPrivateKey: Data,
        chainCode: Data,
        path: String
    ) throws -> (privateKey: Data, chainCode: Data) {
        
        guard path.starts(with: "m/") else {
            throw DerivationError.invalidPath
        }
        
        let components = path.components(separatedBy: "/").dropFirst()
        var currentPrivateKey = masterPrivateKey
        var currentChainCode = chainCode
        
        for component in components {
            let isHardened = component.hasSuffix("'")
            guard let index = UInt32(isHardened ? String(component.dropLast()) : component) else {
                throw DerivationError.invalidPath
            }
            
            let result = try deriveChild(
                parentPrivateKey: currentPrivateKey,
                parentChainCode: currentChainCode,
                index: index,
                hardened: isHardened
            )
            currentPrivateKey = result.privateKey
            currentChainCode = result.chainCode
        }
        
        return (currentPrivateKey, currentChainCode)
    }
    
    // MARK: - Core Derivation Logic
    
    /**
     Derives a single child key from its parent according to BIP32.
     */
    private static func deriveChild(
        parentPrivateKey: Data,
        parentChainCode: Data,
        index: UInt32,
        hardened: Bool
    ) throws -> (privateKey: Data, chainCode: Data) {
        
        var hmacInput = Data()
        let indexData = Data(withUnsafeBytes(of: (hardened ? index | 0x80000000 : index).bigEndian, Array.init))
        
        if hardened {
            // Hardened derivation: 0x00 || parent private key || index
            hmacInput += Data([0x00])
            hmacInput += parentPrivateKey
            hmacInput += indexData
        } else {
            // Non-hardened derivation: parent public key || index
            // ⚠️ ** ACTION REQUIRED ** ⚠️
            // You must provide your own function to get a public key from a private key.
            guard let parentPublicKey = computePublicKey(from: parentPrivateKey, compressed: true) else {
                print("❌ Failed to compute public key for non-hardened derivation.")
                throw DerivationError.derivationFailed
            }
            hmacInput += parentPublicKey
            hmacInput += indexData
        }
        
        let hmac = hmacsha512(data: hmacInput, key: parentChainCode)
        let tweak = hmac[0..<32]         // I_L
        let newChainCode = hmac[32..<64] // I_R
        
        // Calculate the new private key: (tweak + parentPrivateKey) mod n
        guard let derivedPrivateKey = add(privateKey: tweak, to: parentPrivateKey) else {
            print("❌ Derivation resulted in an invalid key (out of curve order).")
            throw DerivationError.invalidPrivateKey
        }
        
        return (derivedPrivateKey, newChainCode)
    }
    
    // MARK: - Cryptographic Helpers
    
    /// Computes HMAC-SHA512.
    private static func hmacsha512(data: Data, key: Data) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes { dataBytes in
            key.withUnsafeBytes { keyBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512), keyBytes.baseAddress, key.count, dataBytes.baseAddress, data.count, &digest)
            }
        }
        return Data(digest)
    }
    
    /// Safely adds two private keys (as scalars) modulo the curve order `n`.
    private static func add(privateKey tweak: Data, to parentPrivateKey: Data) -> Data? {
        let tweakInt = BigUInt(tweak)
        let parentInt = BigUInt(parentPrivateKey)
        
        // Check if tweak is valid
        guard tweakInt < curveOrder else { return nil }
        
        let sum = (tweakInt + parentInt) % curveOrder
        
        // Check if the result is zero, which is an invalid key
        guard sum != 0 else { return nil }
        
        return sum.serialize().padded(toSize: 32)
    }
    
    // MARK: - Placeholder for Public Key Generation
    
    /**
     ⚠️ **ACTION REQUIRED**: Replace this with your existing function for secp256k1 public key generation.
     This is the function that your `_HDKey` or `_SwiftKey` library probably uses internally.
     */
    private static func computePublicKey(from privateKeyData: Data, compressed: Bool) -> Data? {
        
        // 1. Create a PrivateKey object from the raw data.
        //    We must specify the network and that we want a compressed public key.
        //    ⚠️ IMPORTANT: Make sure you use your actual `.xvg` network object here.
        let privateKeyObject = PrivateKey(data: privateKeyData, network: .mainnetXVG, isPublicKeyCompressed: compressed)
        
        // 2. Get the corresponding PublicKey object.
        let publicKeyObject = privateKeyObject.publicKey()
        
        // 3. Return the raw bytes of the public key.
        //    Based on your source, this is almost certainly `.data`.
        return publicKeyObject.data
    }
}


// MARK: - Data Extensions for Convenience

extension Data {
    /// Returns a hexadecimal string representation of the data.
//    var hexString: String {
//        return map { String(format: "%02x", $0) }.joined()
//    }
    
    /// Pads the data to a specific size with leading zeros.
    func padded(toSize size: Int) -> Data {
        let paddingCount = size - self.count
        guard paddingCount > 0 else { return self }
        return Data(repeating: 0, count: paddingCount) + self
    }
}
