//
//  Untitled.swift
//  VergeiOS
//
//  Created by shami kapoor on 27/09/25.
//  Copyright © 2025 Verge Currency. All rights reserved.
//

import Foundation

/// Pure Swift implementation of RIPEMD-160 hash function.
/// Used in Bitcoin for hash160 = RIPEMD160(SHA256(x))
struct RIPEMD160 {
    public init() {}

    public func calculate(for bytes: [UInt8]) -> [UInt8] {
        let padded = padMessage(bytes)
        let blocks = padded.split(into: 64)

        var h0: UInt32 = 0x67452301
        var h1: UInt32 = 0xEFCDAB89
        var h2: UInt32 = 0x98BADCFE
        var h3: UInt32 = 0x10325476
        var h4: UInt32 = 0xC3D2E1F0

        for block in blocks {
            let words = block.to32BitWords(littleEndian: true)

            var a = h0, b = h1, c = h2, d = h3, e = h4

            // Round 1
            for j in 0..<16 {
                let i = j % 16
                let temp = (a &+ f(0, b, c, d) &+ words[rr1(i)] &+ k1(j)) &<< rotate1(i)
                (a, b, c, d, e) = (e, temp, b &<< 10 | b >> 22, c, d)
            }
            // Round 2
            for j in 0..<16 {
                let i = j % 16
                let temp = (a &+ f(16 + j, b, c, d) &+ words[rr2(i)] &+ k2(j)) &<< rotate2(i)
                (a, b, c, d, e) = (e, temp, b &<< 10 | b >> 22, c, d)
            }
            // Round 3
            for j in 0..<16 {
                let i = j % 16
                let temp = (a &+ f(32 + j, b, c, d) &+ words[rr3(i)] &+ k3(j)) &<< rotate3(i)
                (a, b, c, d, e) = (e, temp, b &<< 10 | b >> 22, c, d)
            }
            // Round 4
            for j in 0..<16 {
                let i = j % 16
                let temp = (a &+ f(48 + j, b, c, d) &+ words[rr4(i)] &+ k4(j)) &<< rotate4(i)
                (a, b, c, d, e) = (e, temp, b &<< 10 | b >> 22, c, d)
            }
            // Round 5
            for j in 0..<16 {
                let i = j % 16
                let temp = (a &+ f(64 + j, b, c, d) &+ words[rr5(i)] &+ k5(j)) &<< rotate5(i)
                (a, b, c, d, e) = (e, temp, b &<< 10 | b >> 22, c, d)
            }

            h0 &+= a
            h1 &+= b
            h2 &+= c
            h3 &+= d
            h4 &+= e
        }

        return h0.bytes() + h1.bytes() + h2.bytes() + h3.bytes() + h4.bytes()
    }
}

// MARK: - Helpers

private extension RIPEMD160 {
    func f(_ j: Int, _ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
        if j < 16      { x ^ y ^ z }
        else if j < 32 { (x & y) | (~x & z) }
        else if j < 48 { (x | ~y) ^ z }
        else if j < 64 { (x & z) | (y & ~z) }
        else           { x ^ (y | ~z) }
    }

    func k1(_ j: Int) -> UInt32 { 0 }
    func k2(_ j: Int) -> UInt32 { j < 8 ? 0x5A827999 : 0x6ED9EBA1 }
    func k3(_ j: Int) -> UInt32 { j < 8 ? 0x8F1BBCDC : 0xA953FD4E }
    func k4(_ j: Int) -> UInt32 { j < 8 ? 0x75A2E4D8 : 0x00000000 }
    func k5(_ j: Int) -> UInt32 { j < 8 ? 0x50A28BE6 : 0x5C4DD124 }

    func rr1(_ i: Int) -> Int { [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15][i] }
    func rr2(_ i: Int) -> Int { [5,14,7,0,9,2,11,4,13,6,15,8,1,10,3,12][i] }
    func rr3(_ i: Int) -> Int { [8,13,4,9,0,5,12,1,10,3,14,7,6,15,2,11][i] }
    func rr4(_ i: Int) -> Int { [12,1,14,5,8,3,10,15,6,13,0,7,4,9,2,11][i] }
    func rr5(_ i: Int) -> Int { [1,8,11,14,15,4,9,2,7,0,3,10,13,6,12,5][i] }

    func rotate1(_ i: Int) -> Int { [11,14,15,12,5,8,7,9,11,13,14,15,6,7,9,8][i] }
    func rotate2(_ i: Int) -> Int { [8,9,9,11,13,15,15,5,7,7,8,11,14,14,12,6][i] }
    func rotate3(_ i: Int) -> Int { [10,15,5,11,6,8,13,12,5,12,13,14,11,8,5,6][i] }
    func rotate4(_ i: Int) -> Int { [7,6,8,13,11,9,7,15,7,12,15,9,11,7,13,12][i] }
    func rotate5(_ i: Int) -> Int { [6,14,11,9,13,15,15,5,8,11,14,14,6,14,6,9][i] }
}

private extension Array where Element == UInt8 {
    func split(into size: Int) -> [[UInt8]] {
        var result: [[UInt8]] = []
        for i in stride(from: 0, to: count, by: size) {
            result.append(Array(self[i..<Swift.min(i + size, count)]))
        }
        return result
    }

    func to32BitWords(littleEndian: Bool) -> [UInt32] {
        var words: [UInt32] = []
        for i in 0..<(count / 4) {
            let base = i * 4
            let w: UInt32 = (
                UInt32(self[base + (littleEndian ? 0 : 3)]) << (littleEndian ? 0 : 24) |
                UInt32(self[base + (littleEndian ? 1 : 2)]) << (littleEndian ? 8 : 16) |
                UInt32(self[base + (littleEndian ? 2 : 1)]) << (littleEndian ? 16 : 8) |
                UInt32(self[base + (littleEndian ? 3 : 0)]) << (littleEndian ? 24 : 0)
            )
            words.append(w)
        }
        return words
    }
}

private extension UInt32 {
    func bytes() -> [UInt8] {
        return [
            UInt8(self & 0xff),
            UInt8((self >> 8) & 0xff),
            UInt8((self >> 16) & 0xff),
            UInt8((self >> 24) & 0xff)
        ]
    }
}

private extension RIPEMD160 {
    func padMessage(_ message: [UInt8]) -> [UInt8] {
        var padded = message
        let bitLen = message.count * 8

        padded.append(0x80) // Append 1 bit + zeros

        while (padded.count % 64) != 56 {
            padded.append(0x00)
        }

        let lowBits = UInt32(bitLen & 0xFFFFFFFF)
        let highBits = UInt32((bitLen >> 32) & 0xFFFFFFFF)

        padded += lowBits.bytes()
        padded += highBits.bytes()

        return padded
    }
}
