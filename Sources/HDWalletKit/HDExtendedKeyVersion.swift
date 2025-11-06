import HsExtensions

// https://github.com/satoshilabs/slips/blob/master/slip-0132.md
public enum HDExtendedKeyVersion: UInt32, CaseIterable {
    case xprv = 0x0488ade4
    case xpub = 0x0488b21e
    case yprv = 0x049d7878
    case ypub = 0x049d7cb2
    case zprv = 0x04b2430c
    case zpub = 0x04b24746
    case Ltpv = 0x019d9cfe
    case Ltub = 0x019da462
    case Mtpv = 0x01b26792
    case Mtub = 0x01b26ef6

    public init(purpose: Purpose, coinType: ExtendedKeyCoinType, isPrivate: Bool = true) throws {
        switch purpose {
        case .bip44:
            switch coinType {
            case .bitcoin: self = isPrivate ? .xprv : .xpub
            case .litecoin: self = isPrivate ? .Ltpv : .Ltub
            }
        case .bip49:
            switch coinType {
            case .bitcoin: self = isPrivate ? .yprv : .ypub
            case .litecoin: self = isPrivate ? .Mtpv : .Mtub
            }
        case .bip84:
            self = isPrivate ? .zprv : .zpub
        case .bip86:
            self = isPrivate ? .xprv : .xpub
        }
    }

    public init?(string: String) {
        guard let result = Self.allCases.first(where: { $0.string == string }) else {
            return nil
        }

        self = result
    }

    public var string: String {
        switch self {
        case .xprv: return "xprv"
        case .xpub: return "xpub"
        case .yprv: return "yprv"
        case .ypub: return "ypub"
        case .zprv: return "zprv"
        case .zpub: return "zpub"
        case .Ltpv: return "Ltpv"
        case .Ltub: return "Ltub"
        case .Mtpv: return "Mtpv"
        case .Mtub: return "Mtub"
        }
    }

    public var purposes: [Purpose] {
        switch self {
        case .xprv, .xpub: return [.bip44, .bip86]
        case .Ltpv, .Ltub: return [.bip44]
        case .yprv, .ypub, .Mtpv, .Mtub: return [.bip49]
        case .zprv, .zpub: return [.bip84]
        }
    }

    public var coinTypes: [ExtendedKeyCoinType] {
        switch self {
        case .xprv, .xpub, .zprv, .zpub: return [.bitcoin, .litecoin]
        case .yprv, .ypub: return [.bitcoin]
        case .Ltpv, .Ltub, .Mtpv, .Mtub: return [.litecoin]
        }
    }

    public var pubKey: Self {
        switch self {
        case .xprv: return .xpub
        case .yprv: return .ypub
        case .zprv: return .zpub
        case .Ltpv: return .Ltub
        case .Mtpv: return .Mtub
        default: return self
        }
    }

    public var isPublic: Bool {
        switch self {
        case .xpub, .ypub, .zpub, .Ltub, .Mtub: return true
        default: return false
        }
    }

}

extension HDExtendedKeyVersion {

    public enum ExtendedKeyCoinType {
        case bitcoin
        case litecoin
    }

}
