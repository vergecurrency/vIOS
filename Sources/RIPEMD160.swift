import Foundation

struct RIPEMD160 {
    private var state: (UInt32, UInt32, UInt32, UInt32, UInt32)
    private var buffer: Data
    private var byteCount: Int64

    private init() {
        state = (0x6745_2301, 0xEFCD_AB89, 0x98BA_DCFE, 0x1032_5476, 0xC3D2_E1F0)
        buffer = Data()
        byteCount = 0
    }

    func calculate(for bytes: [UInt8]) -> [UInt8] {
        return Array(Self.hash(Data(bytes)))
    }

    static func hash(_ message: Data) -> Data {
        var digest = RIPEMD160()
        digest.update(data: message)
        return digest.finalize()
    }

    private mutating func update(data: Data) {
        data.withUnsafeBytes { pointer in
            guard var ptr = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
            var length = data.count
            var block = [UInt32](repeating: 0, count: 16)

            if !buffer.isEmpty, buffer.count + length >= 64 {
                let amount = 64 - buffer.count
                buffer.append(ptr, count: amount)
                buffer.withUnsafeBytes { rawBuffer in
                    _ = memcpy(&block, rawBuffer.baseAddress, 64)
                }
                compress(block)
                buffer.removeAll(keepingCapacity: true)
                ptr += amount
                length -= amount
            }

            while length >= 64 {
                memcpy(&block, ptr, 64)
                compress(block)
                ptr += 64
                length -= 64
            }

            buffer = Data(bytes: ptr, count: length)
        }

        byteCount += Int64(data.count)
    }

    private mutating func finalize() -> Data {
        var block = [UInt32](repeating: 0, count: 16)
        buffer.append(0x80)
        buffer.withUnsafeBytes { rawBuffer in
            _ = memcpy(&block, rawBuffer.baseAddress, buffer.count)
        }

        if (byteCount & 63) > 55 {
            compress(block)
            block = [UInt32](repeating: 0, count: 16)
        }

        let low = UInt32(truncatingIfNeeded: byteCount)
        let high = UInt32(UInt64(byteCount) >> 32)
        block[14] = low << 3
        block[15] = (low >> 29) | (high << 3)
        compress(block)

        var data = Data(count: 20)
        data.withUnsafeMutableBytes { pointer in
            let words = pointer.bindMemory(to: UInt32.self)
            words[0] = state.0
            words[1] = state.1
            words[2] = state.2
            words[3] = state.3
            words[4] = state.4
        }

        return data
    }

    private mutating func compress(_ block: [UInt32]) {
        func rotateLeft(_ value: UInt32, _ bits: UInt32) -> UInt32 {
            return (value << bits) | (value >> (32 - bits))
        }

        func f(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 { x ^ y ^ z }
        func g(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 { (x & y) | (~x & z) }
        func h(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 { (x | ~y) ^ z }
        func i(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 { (x & z) | (y & ~z) }
        func j(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 { x ^ (y | ~z) }

        func step(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ e: UInt32, _ x: UInt32, _ s: UInt32, _ fn: (UInt32, UInt32, UInt32) -> UInt32, _ k: UInt32) {
            a = rotateLeft(a &+ fn(b, c, d) &+ x &+ k, s) &+ e
            c = rotateLeft(c, 10)
        }

        var (aa, bb, cc, dd, ee) = state
        var (aaa, bbb, ccc, ddd, eee) = state

        step(&aa, bb, &cc, dd, ee, block[0], 11, f, 0)
        step(&ee, aa, &bb, cc, dd, block[1], 14, f, 0)
        step(&dd, ee, &aa, bb, cc, block[2], 15, f, 0)
        step(&cc, dd, &ee, aa, bb, block[3], 12, f, 0)
        step(&bb, cc, &dd, ee, aa, block[4], 5, f, 0)
        step(&aa, bb, &cc, dd, ee, block[5], 8, f, 0)
        step(&ee, aa, &bb, cc, dd, block[6], 7, f, 0)
        step(&dd, ee, &aa, bb, cc, block[7], 9, f, 0)
        step(&cc, dd, &ee, aa, bb, block[8], 11, f, 0)
        step(&bb, cc, &dd, ee, aa, block[9], 13, f, 0)
        step(&aa, bb, &cc, dd, ee, block[10], 14, f, 0)
        step(&ee, aa, &bb, cc, dd, block[11], 15, f, 0)
        step(&dd, ee, &aa, bb, cc, block[12], 6, f, 0)
        step(&cc, dd, &ee, aa, bb, block[13], 7, f, 0)
        step(&bb, cc, &dd, ee, aa, block[14], 9, f, 0)
        step(&aa, bb, &cc, dd, ee, block[15], 8, f, 0)

        step(&ee, aa, &bb, cc, dd, block[7], 7, g, 0x5A82_7999)
        step(&dd, ee, &aa, bb, cc, block[4], 6, g, 0x5A82_7999)
        step(&cc, dd, &ee, aa, bb, block[13], 8, g, 0x5A82_7999)
        step(&bb, cc, &dd, ee, aa, block[1], 13, g, 0x5A82_7999)
        step(&aa, bb, &cc, dd, ee, block[10], 11, g, 0x5A82_7999)
        step(&ee, aa, &bb, cc, dd, block[6], 9, g, 0x5A82_7999)
        step(&dd, ee, &aa, bb, cc, block[15], 7, g, 0x5A82_7999)
        step(&cc, dd, &ee, aa, bb, block[3], 15, g, 0x5A82_7999)
        step(&bb, cc, &dd, ee, aa, block[12], 7, g, 0x5A82_7999)
        step(&aa, bb, &cc, dd, ee, block[0], 12, g, 0x5A82_7999)
        step(&ee, aa, &bb, cc, dd, block[9], 15, g, 0x5A82_7999)
        step(&dd, ee, &aa, bb, cc, block[5], 9, g, 0x5A82_7999)
        step(&cc, dd, &ee, aa, bb, block[2], 11, g, 0x5A82_7999)
        step(&bb, cc, &dd, ee, aa, block[14], 7, g, 0x5A82_7999)
        step(&aa, bb, &cc, dd, ee, block[11], 13, g, 0x5A82_7999)
        step(&ee, aa, &bb, cc, dd, block[8], 12, g, 0x5A82_7999)

        step(&dd, ee, &aa, bb, cc, block[3], 11, h, 0x6ED9_EBA1)
        step(&cc, dd, &ee, aa, bb, block[10], 13, h, 0x6ED9_EBA1)
        step(&bb, cc, &dd, ee, aa, block[14], 6, h, 0x6ED9_EBA1)
        step(&aa, bb, &cc, dd, ee, block[4], 7, h, 0x6ED9_EBA1)
        step(&ee, aa, &bb, cc, dd, block[9], 14, h, 0x6ED9_EBA1)
        step(&dd, ee, &aa, bb, cc, block[15], 9, h, 0x6ED9_EBA1)
        step(&cc, dd, &ee, aa, bb, block[8], 13, h, 0x6ED9_EBA1)
        step(&bb, cc, &dd, ee, aa, block[1], 15, h, 0x6ED9_EBA1)
        step(&aa, bb, &cc, dd, ee, block[2], 14, h, 0x6ED9_EBA1)
        step(&ee, aa, &bb, cc, dd, block[7], 8, h, 0x6ED9_EBA1)
        step(&dd, ee, &aa, bb, cc, block[0], 13, h, 0x6ED9_EBA1)
        step(&cc, dd, &ee, aa, bb, block[6], 6, h, 0x6ED9_EBA1)
        step(&bb, cc, &dd, ee, aa, block[13], 5, h, 0x6ED9_EBA1)
        step(&aa, bb, &cc, dd, ee, block[11], 12, h, 0x6ED9_EBA1)
        step(&ee, aa, &bb, cc, dd, block[5], 7, h, 0x6ED9_EBA1)
        step(&dd, ee, &aa, bb, cc, block[12], 5, h, 0x6ED9_EBA1)

        step(&cc, dd, &ee, aa, bb, block[1], 11, i, 0x8F1B_BCDC)
        step(&bb, cc, &dd, ee, aa, block[9], 12, i, 0x8F1B_BCDC)
        step(&aa, bb, &cc, dd, ee, block[11], 14, i, 0x8F1B_BCDC)
        step(&ee, aa, &bb, cc, dd, block[10], 15, i, 0x8F1B_BCDC)
        step(&dd, ee, &aa, bb, cc, block[0], 14, i, 0x8F1B_BCDC)
        step(&cc, dd, &ee, aa, bb, block[8], 15, i, 0x8F1B_BCDC)
        step(&bb, cc, &dd, ee, aa, block[12], 9, i, 0x8F1B_BCDC)
        step(&aa, bb, &cc, dd, ee, block[4], 8, i, 0x8F1B_BCDC)
        step(&ee, aa, &bb, cc, dd, block[13], 9, i, 0x8F1B_BCDC)
        step(&dd, ee, &aa, bb, cc, block[3], 14, i, 0x8F1B_BCDC)
        step(&cc, dd, &ee, aa, bb, block[7], 5, i, 0x8F1B_BCDC)
        step(&bb, cc, &dd, ee, aa, block[15], 6, i, 0x8F1B_BCDC)
        step(&aa, bb, &cc, dd, ee, block[14], 8, i, 0x8F1B_BCDC)
        step(&ee, aa, &bb, cc, dd, block[5], 6, i, 0x8F1B_BCDC)
        step(&dd, ee, &aa, bb, cc, block[6], 5, i, 0x8F1B_BCDC)
        step(&cc, dd, &ee, aa, bb, block[2], 12, i, 0x8F1B_BCDC)

        step(&bb, cc, &dd, ee, aa, block[4], 9, j, 0xA953_FD4E)
        step(&aa, bb, &cc, dd, ee, block[0], 15, j, 0xA953_FD4E)
        step(&ee, aa, &bb, cc, dd, block[5], 5, j, 0xA953_FD4E)
        step(&dd, ee, &aa, bb, cc, block[9], 11, j, 0xA953_FD4E)
        step(&cc, dd, &ee, aa, bb, block[7], 6, j, 0xA953_FD4E)
        step(&bb, cc, &dd, ee, aa, block[12], 8, j, 0xA953_FD4E)
        step(&aa, bb, &cc, dd, ee, block[2], 13, j, 0xA953_FD4E)
        step(&ee, aa, &bb, cc, dd, block[10], 12, j, 0xA953_FD4E)
        step(&dd, ee, &aa, bb, cc, block[14], 5, j, 0xA953_FD4E)
        step(&cc, dd, &ee, aa, bb, block[1], 12, j, 0xA953_FD4E)
        step(&bb, cc, &dd, ee, aa, block[3], 13, j, 0xA953_FD4E)
        step(&aa, bb, &cc, dd, ee, block[8], 14, j, 0xA953_FD4E)
        step(&ee, aa, &bb, cc, dd, block[11], 11, j, 0xA953_FD4E)
        step(&dd, ee, &aa, bb, cc, block[6], 8, j, 0xA953_FD4E)
        step(&cc, dd, &ee, aa, bb, block[15], 5, j, 0xA953_FD4E)
        step(&bb, cc, &dd, ee, aa, block[13], 6, j, 0xA953_FD4E)

        step(&aaa, bbb, &ccc, ddd, eee, block[5], 8, j, 0x50A2_8BE6)
        step(&eee, aaa, &bbb, ccc, ddd, block[14], 9, j, 0x50A2_8BE6)
        step(&ddd, eee, &aaa, bbb, ccc, block[7], 9, j, 0x50A2_8BE6)
        step(&ccc, ddd, &eee, aaa, bbb, block[0], 11, j, 0x50A2_8BE6)
        step(&bbb, ccc, &ddd, eee, aaa, block[9], 13, j, 0x50A2_8BE6)
        step(&aaa, bbb, &ccc, ddd, eee, block[2], 15, j, 0x50A2_8BE6)
        step(&eee, aaa, &bbb, ccc, ddd, block[11], 15, j, 0x50A2_8BE6)
        step(&ddd, eee, &aaa, bbb, ccc, block[4], 5, j, 0x50A2_8BE6)
        step(&ccc, ddd, &eee, aaa, bbb, block[13], 7, j, 0x50A2_8BE6)
        step(&bbb, ccc, &ddd, eee, aaa, block[6], 7, j, 0x50A2_8BE6)
        step(&aaa, bbb, &ccc, ddd, eee, block[15], 8, j, 0x50A2_8BE6)
        step(&eee, aaa, &bbb, ccc, ddd, block[8], 11, j, 0x50A2_8BE6)
        step(&ddd, eee, &aaa, bbb, ccc, block[1], 14, j, 0x50A2_8BE6)
        step(&ccc, ddd, &eee, aaa, bbb, block[10], 14, j, 0x50A2_8BE6)
        step(&bbb, ccc, &ddd, eee, aaa, block[3], 12, j, 0x50A2_8BE6)
        step(&aaa, bbb, &ccc, ddd, eee, block[12], 6, j, 0x50A2_8BE6)

        step(&eee, aaa, &bbb, ccc, ddd, block[6], 9, i, 0x5C4D_D124)
        step(&ddd, eee, &aaa, bbb, ccc, block[11], 13, i, 0x5C4D_D124)
        step(&ccc, ddd, &eee, aaa, bbb, block[3], 15, i, 0x5C4D_D124)
        step(&bbb, ccc, &ddd, eee, aaa, block[7], 7, i, 0x5C4D_D124)
        step(&aaa, bbb, &ccc, ddd, eee, block[0], 12, i, 0x5C4D_D124)
        step(&eee, aaa, &bbb, ccc, ddd, block[13], 8, i, 0x5C4D_D124)
        step(&ddd, eee, &aaa, bbb, ccc, block[5], 9, i, 0x5C4D_D124)
        step(&ccc, ddd, &eee, aaa, bbb, block[10], 11, i, 0x5C4D_D124)
        step(&bbb, ccc, &ddd, eee, aaa, block[14], 7, i, 0x5C4D_D124)
        step(&aaa, bbb, &ccc, ddd, eee, block[15], 7, i, 0x5C4D_D124)
        step(&eee, aaa, &bbb, ccc, ddd, block[8], 12, i, 0x5C4D_D124)
        step(&ddd, eee, &aaa, bbb, ccc, block[12], 7, i, 0x5C4D_D124)
        step(&ccc, ddd, &eee, aaa, bbb, block[4], 6, i, 0x5C4D_D124)
        step(&bbb, ccc, &ddd, eee, aaa, block[9], 15, i, 0x5C4D_D124)
        step(&aaa, bbb, &ccc, ddd, eee, block[1], 13, i, 0x5C4D_D124)
        step(&eee, aaa, &bbb, ccc, ddd, block[2], 11, i, 0x5C4D_D124)

        step(&ddd, eee, &aaa, bbb, ccc, block[15], 9, h, 0x6D70_3EF3)
        step(&ccc, ddd, &eee, aaa, bbb, block[5], 7, h, 0x6D70_3EF3)
        step(&bbb, ccc, &ddd, eee, aaa, block[1], 15, h, 0x6D70_3EF3)
        step(&aaa, bbb, &ccc, ddd, eee, block[3], 11, h, 0x6D70_3EF3)
        step(&eee, aaa, &bbb, ccc, ddd, block[7], 8, h, 0x6D70_3EF3)
        step(&ddd, eee, &aaa, bbb, ccc, block[14], 6, h, 0x6D70_3EF3)
        step(&ccc, ddd, &eee, aaa, bbb, block[6], 6, h, 0x6D70_3EF3)
        step(&bbb, ccc, &ddd, eee, aaa, block[9], 14, h, 0x6D70_3EF3)
        step(&aaa, bbb, &ccc, ddd, eee, block[11], 12, h, 0x6D70_3EF3)
        step(&eee, aaa, &bbb, ccc, ddd, block[8], 13, h, 0x6D70_3EF3)
        step(&ddd, eee, &aaa, bbb, ccc, block[12], 5, h, 0x6D70_3EF3)
        step(&ccc, ddd, &eee, aaa, bbb, block[2], 14, h, 0x6D70_3EF3)
        step(&bbb, ccc, &ddd, eee, aaa, block[10], 13, h, 0x6D70_3EF3)
        step(&aaa, bbb, &ccc, ddd, eee, block[0], 13, h, 0x6D70_3EF3)
        step(&eee, aaa, &bbb, ccc, ddd, block[4], 7, h, 0x6D70_3EF3)
        step(&ddd, eee, &aaa, bbb, ccc, block[13], 5, h, 0x6D70_3EF3)

        step(&ccc, ddd, &eee, aaa, bbb, block[8], 15, g, 0x7A6D_76E9)
        step(&bbb, ccc, &ddd, eee, aaa, block[6], 5, g, 0x7A6D_76E9)
        step(&aaa, bbb, &ccc, ddd, eee, block[4], 8, g, 0x7A6D_76E9)
        step(&eee, aaa, &bbb, ccc, ddd, block[1], 11, g, 0x7A6D_76E9)
        step(&ddd, eee, &aaa, bbb, ccc, block[3], 14, g, 0x7A6D_76E9)
        step(&ccc, ddd, &eee, aaa, bbb, block[11], 14, g, 0x7A6D_76E9)
        step(&bbb, ccc, &ddd, eee, aaa, block[15], 6, g, 0x7A6D_76E9)
        step(&aaa, bbb, &ccc, ddd, eee, block[0], 14, g, 0x7A6D_76E9)
        step(&eee, aaa, &bbb, ccc, ddd, block[5], 6, g, 0x7A6D_76E9)
        step(&ddd, eee, &aaa, bbb, ccc, block[12], 9, g, 0x7A6D_76E9)
        step(&ccc, ddd, &eee, aaa, bbb, block[2], 12, g, 0x7A6D_76E9)
        step(&bbb, ccc, &ddd, eee, aaa, block[13], 9, g, 0x7A6D_76E9)
        step(&aaa, bbb, &ccc, ddd, eee, block[9], 12, g, 0x7A6D_76E9)
        step(&eee, aaa, &bbb, ccc, ddd, block[7], 5, g, 0x7A6D_76E9)
        step(&ddd, eee, &aaa, bbb, ccc, block[10], 15, g, 0x7A6D_76E9)
        step(&ccc, ddd, &eee, aaa, bbb, block[14], 8, g, 0x7A6D_76E9)

        step(&bbb, ccc, &ddd, eee, aaa, block[12], 8, f, 0)
        step(&aaa, bbb, &ccc, ddd, eee, block[15], 5, f, 0)
        step(&eee, aaa, &bbb, ccc, ddd, block[10], 12, f, 0)
        step(&ddd, eee, &aaa, bbb, ccc, block[4], 9, f, 0)
        step(&ccc, ddd, &eee, aaa, bbb, block[1], 12, f, 0)
        step(&bbb, ccc, &ddd, eee, aaa, block[5], 5, f, 0)
        step(&aaa, bbb, &ccc, ddd, eee, block[8], 14, f, 0)
        step(&eee, aaa, &bbb, ccc, ddd, block[7], 6, f, 0)
        step(&ddd, eee, &aaa, bbb, ccc, block[6], 8, f, 0)
        step(&ccc, ddd, &eee, aaa, bbb, block[2], 13, f, 0)
        step(&bbb, ccc, &ddd, eee, aaa, block[13], 6, f, 0)
        step(&aaa, bbb, &ccc, ddd, eee, block[14], 5, f, 0)
        step(&eee, aaa, &bbb, ccc, ddd, block[0], 15, f, 0)
        step(&ddd, eee, &aaa, bbb, ccc, block[3], 13, f, 0)
        step(&ccc, ddd, &eee, aaa, bbb, block[9], 11, f, 0)
        step(&bbb, ccc, &ddd, eee, aaa, block[11], 11, f, 0)

        state = (
            state.1 &+ cc &+ ddd,
            state.2 &+ dd &+ eee,
            state.3 &+ ee &+ aaa,
            state.4 &+ aa &+ bbb,
            state.0 &+ bb &+ ccc
        )
    }
}
