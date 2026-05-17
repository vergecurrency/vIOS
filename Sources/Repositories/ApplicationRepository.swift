//
//  ApplicationRepository.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import KeychainSwift

struct WalletProfile: Codable, Equatable {
    let id: String
    var name: String
    var walletId: String?
    var copayerId: String?
}

class ApplicationRepository {
    static let createdWalletMnemonicWordCount = 18
    static let supportedMnemonicWordCounts: Set<Int> = [12, 18]
    static let maxMnemonicWordCount = 18
    static let defaultElectrumXServers = [
        ElectrumXServer(host: "electrumx-verge.cloud", port: 50002, useTLS: true),
        ElectrumXServer(host: "electrum-verge.cloud", port: 50002, useTLS: true)
    ]

    private let keychain = KeychainSwift(keyPrefix: "verge_")
    private let userDefaults = UserDefaults.standard
    private let legacyWalletProfileId = "default"
    private let activeWalletProfileIdKey = "wallet.activeProfileId"
    private let pendingSetupWalletProfileIdKey = "wallet.pendingSetupProfileId"
    private let walletProfilesKey = "wallet.profiles"
    private let electrumXServersKey = "wallet.electrumx.servers"
    private let activeElectrumXServerKey = "wallet.electrumx.activeServer"

    // Store the latest fiat rate on application level.
    var latestRateInfo: FiatRate?
    var pendingRestoreMnemonic: [String]?
    var pendingSetupPassphrase: String?
    var pendingWalletSecret: String?

    // Is the wallet already setup?
    var setup: Bool {
        return self.hasActiveWalletRecoveryMaterial && self.pin != ""
    }

    var hasActiveWalletMaterial: Bool {
        guard let mnemonic = self.mnemonic else {
            return false
        }

        return isSupportedMnemonic(mnemonic)
            && (!requiresSetupPassphrase(mnemonic: mnemonic) || (self.passphrase?.count ?? 0) > 7)
            && self.walletId != nil
    }

    var hasActiveWalletRecoveryMaterial: Bool {
        guard let mnemonic = self.mnemonic else {
            return false
        }

        return isSupportedMnemonic(mnemonic)
            && (!requiresSetupPassphrase(mnemonic: mnemonic) || (self.passphrase?.count ?? 0) > 7)
    }

    var activeWalletProfileId: String {
        get {
            if let stored = userDefaults.string(forKey: activeWalletProfileIdKey), !stored.isEmpty {
                return stored
            }

            return legacyWalletProfileId
        }
        set {
            userDefaults.set(newValue, forKey: activeWalletProfileIdKey)
        }
    }

    var walletProfiles: [WalletProfile] {
        get {
            if let data = userDefaults.data(forKey: walletProfilesKey),
               let profiles = try? JSONDecoder().decode([WalletProfile].self, from: data),
               !profiles.isEmpty {
                return profiles
            }

            if hasLegacyWalletData {
                return [
                    WalletProfile(
                        id: legacyWalletProfileId,
                        name: walletName ?? "Wallet 1",
                        walletId: walletId,
                        copayerId: copayerId
                    )
                ]
            }

            return []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }

            userDefaults.set(data, forKey: walletProfilesKey)
        }
    }

    var activeWalletProfile: WalletProfile? {
        walletProfiles.first { $0.id == activeWalletProfileId }
    }

    var usableWalletProfiles: [WalletProfile] {
        return walletProfiles.filter { hasWalletRecoveryMaterial(profileId: $0.id) }
    }

    var hasAnyWalletProfile: Bool {
        return !usableWalletProfiles.isEmpty
    }

    private var hasLegacyWalletData: Bool {
        keychain.get("wallet.id") != nil || keychain.get("mnemonic.word.0") != nil
    }

    private var usesLegacyWalletKeys: Bool {
        activeWalletProfileId == legacyWalletProfileId
    }

    private var pendingSetupWalletProfileId: String? {
        get {
            userDefaults.string(forKey: pendingSetupWalletProfileIdKey)
        }
        set {
            if let newValue = newValue {
                userDefaults.set(newValue, forKey: pendingSetupWalletProfileIdKey)
            } else {
                userDefaults.removeObject(forKey: pendingSetupWalletProfileIdKey)
            }
        }
    }

    private var setupWriteWalletProfileId: String {
        pendingSetupWalletProfileId ?? activeWalletProfileId
    }

    private func keychainKey(_ key: String) -> String {
        return keychainKey(key, profileId: activeWalletProfileId)
    }

    private func keychainKey(_ key: String, profileId: String) -> String {
        if profileId == legacyWalletProfileId {
            return key
        }

        return "wallet.profiles.\(profileId).\(key)"
    }

    private func defaultsKey(_ key: String) -> String {
        return defaultsKey(key, profileId: activeWalletProfileId)
    }

    private func defaultsKey(_ key: String, profileId: String) -> String {
        if profileId == legacyWalletProfileId {
            return key
        }

        return "wallet.profiles.\(profileId).\(key)"
    }

    @discardableResult
    private func saveSecureValue(_ value: String, forKey key: String) -> Bool {
        let saved = keychain.set(value, forKey: key, withAccess: .accessibleAfterFirstUnlock)
        if !saved {
            print("Keychain save failed for \(key): \(keychain.lastResultCode)")
        }

        return saved && keychain.get(key) == value
    }

    private func mnemonic(profileId: String) -> [String]? {
        var mnemonic = [String]()

        for index in 0..<Self.maxMnemonicWordCount {
            guard let word = storedMnemonicWord(index: index, profileId: profileId) else {
                break
            }
            mnemonic.append(word)
        }

        if isSupportedMnemonic(mnemonic) {
            return mnemonic
        }

        return profileId == activeWalletProfileId ? pendingRestoreMnemonic : nil
    }

    private func storedMnemonicWord(index: Int, profileId: String) -> String? {
        let secureKey = keychainKey("mnemonic.word.\(index)", profileId: profileId)
        if let word = keychain.get(secureKey) {
            return word
        }

        let legacyDefaultsKey = defaultsKey("mnemonic.word.\(index)", profileId: profileId)
        guard let word = userDefaults.string(forKey: legacyDefaultsKey) else {
            return nil
        }

        if saveSecureValue(word, forKey: secureKey) {
            userDefaults.removeObject(forKey: legacyDefaultsKey)
        }

        return word
    }

    private func isSupportedMnemonic(_ mnemonic: [String]?) -> Bool {
        guard let mnemonic = mnemonic else {
            return false
        }

        return Self.supportedMnemonicWordCounts.contains(mnemonic.count)
    }

    func requiresSetupPassphrase(mnemonic: [String]) -> Bool {
        return mnemonic.count != Self.createdWalletMnemonicWordCount
    }

    private func passphrase(profileId: String) -> String? {
        let secureKey = keychainKey("wallet.passphrase", profileId: profileId)
        if let passphrase = keychain.get(secureKey) {
            return passphrase
        }

        let legacyDefaultsKey = defaultsKey("wallet.passphrase", profileId: profileId)
        guard let passphrase = userDefaults.string(forKey: legacyDefaultsKey) else {
            return nil
        }

        if saveSecureValue(passphrase, forKey: secureKey) {
            userDefaults.removeObject(forKey: legacyDefaultsKey)
        }

        return passphrase
    }

    private func walletId(profileId: String) -> String? {
        return keychain.get(keychainKey("wallet.id", profileId: profileId))
    }

    private func copayerId(profileId: String) -> String? {
        return keychain.get(keychainKey("wallet.copayerId", profileId: profileId))
    }

    func hasWalletMaterial(profileId: String) -> Bool {
        return hasWalletRecoveryMaterial(profileId: profileId)
            && walletId(profileId: profileId) != nil
    }

    func hasWalletRecoveryMaterial(profileId: String) -> Bool {
        guard let mnemonic = mnemonic(profileId: profileId) else {
            return false
        }

        return isSupportedMnemonic(mnemonic)
            && (!requiresSetupPassphrase(mnemonic: mnemonic) || (passphrase(profileId: profileId)?.count ?? 0) > 7)
    }

    private func hasAnyWalletData(profileId: String) -> Bool {
        return mnemonic(profileId: profileId) != nil
            || passphrase(profileId: profileId) != nil
            || walletId(profileId: profileId) != nil
            || copayerId(profileId: profileId) != nil
    }

    func walletMaterialSummary(profileId: String) -> String {
        let mnemonicStatus = mnemonic(profileId: profileId).map { "\($0.count) words" } ?? "no words"
        let passphraseStatus = (passphrase(profileId: profileId)?.count ?? 0) > 7 ? "passphrase" : "no passphrase"
        let walletStatus = walletId(profileId: profileId).map { String($0.prefix(8)) } ?? "no wallet"
        let copayerStatus = copayerId(profileId: profileId).map { String($0.prefix(8)) } ?? "no copayer"

        return "\(mnemonicStatus), \(passphraseStatus), wallet: \(walletStatus), copayer: \(copayerStatus)"
    }

    private func upsertActiveWalletProfile(name: String? = nil, walletId: String? = nil, copayerId: String? = nil) {
        upsertWalletProfile(id: activeWalletProfileId, name: name, walletId: walletId, copayerId: copayerId)
    }

    private func upsertSetupWalletProfile(name: String? = nil, walletId: String? = nil, copayerId: String? = nil) {
        upsertWalletProfile(id: setupWriteWalletProfileId, name: name, walletId: walletId, copayerId: copayerId)
    }

    private func upsertWalletProfile(id: String, name: String? = nil, walletId: String? = nil, copayerId: String? = nil) {
        var profiles = walletProfiles
        let existingProfile = profiles.first { $0.id == id }
        let profileName = name ?? existingProfile?.name ?? "Wallet \(profiles.count + 1)"

        if let index = profiles.firstIndex(where: { $0.id == id }) {
            profiles[index].name = name ?? profiles[index].name
            profiles[index].walletId = walletId ?? profiles[index].walletId
            profiles[index].copayerId = copayerId ?? profiles[index].copayerId
        } else {
            profiles.append(
                WalletProfile(
                    id: id,
                    name: profileName,
                    walletId: walletId,
                    copayerId: copayerId
                )
            )
        }

        walletProfiles = profiles
    }

    func refreshActiveWalletProfile() {
        upsertActiveWalletProfile(walletId: walletId, copayerId: copayerId)
    }

    func finishWalletProfileSetup() {
        if let profileId = pendingSetupWalletProfileId {
            activeWalletProfileId = profileId
            upsertActiveWalletProfile(walletId: walletId, copayerId: copayerId)
        } else {
            refreshActiveWalletProfile()
        }

        pendingSetupWalletProfileId = nil
    }

    func saveSetupPassphrase(_ passphrase: String) {
        pendingSetupPassphrase = passphrase

        if let profileId = pendingSetupWalletProfileId {
            if saveSecureValue(passphrase, forKey: keychainKey("wallet.passphrase", profileId: profileId)) {
                userDefaults.removeObject(forKey: defaultsKey("wallet.passphrase", profileId: profileId))
            }
            upsertWalletProfile(id: profileId)
        }

        if saveSecureValue(passphrase, forKey: keychainKey("wallet.passphrase", profileId: activeWalletProfileId)) {
            userDefaults.removeObject(forKey: defaultsKey("wallet.passphrase", profileId: activeWalletProfileId))
        }
        upsertActiveWalletProfile()
    }

    @discardableResult
    func beginNewWalletProfile(name: String? = nil) -> WalletProfile {
        deleteIncompleteWalletProfiles()

        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let profileName = trimmedName?.isEmpty == false ? trimmedName! : "Wallet \(walletProfiles.count + 1)"
        let profile = WalletProfile(
            id: UUID().uuidString,
            name: profileName,
            walletId: nil,
            copayerId: nil
        )
        var profiles = walletProfiles
        profiles.append(profile)
        walletProfiles = profiles
        activeWalletProfileId = profile.id
        pendingSetupWalletProfileId = profile.id
        clearActiveWalletData()

        return profile
    }

    func deleteIncompleteWalletProfiles() {
        let profiles = walletProfiles
        let emptyProfiles = profiles.filter { !hasAnyWalletData(profileId: $0.id) }

        for profile in emptyProfiles {
            clearWalletData(profileId: profile.id)
        }

        let remainingProfiles = profiles.filter { hasAnyWalletData(profileId: $0.id) }
        walletProfiles = remainingProfiles

        if !remainingProfiles.contains(where: { $0.id == activeWalletProfileId }) {
            activeWalletProfileId = remainingProfiles.first?.id ?? legacyWalletProfileId
        }
    }

    func switchWalletProfile(id: String) {
        guard walletProfiles.contains(where: { $0.id == id }) else {
            return
        }

        activeWalletProfileId = id
        pendingSetupWalletProfileId = nil
        pendingRestoreMnemonic = nil
        pendingSetupPassphrase = nil
        pendingWalletSecret = nil
    }

    @discardableResult
    func selectFirstUsableWalletProfileIfNeeded() -> Bool {
        if setup {
            return true
        }

        guard let profileId = firstUsableWalletProfileId() else {
            return false
        }

        switchWalletProfile(id: profileId)
        return true
    }

    func renameWalletProfile(id: String, name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }

        var profiles = walletProfiles
        guard let index = profiles.firstIndex(where: { $0.id == id }) else {
            return
        }

        profiles[index].name = trimmedName
        walletProfiles = profiles
    }

    func deleteActiveWalletProfile() {
        let deletingLegacyProfile = usesLegacyWalletKeys
        clearActiveWalletData()

        let profiles = walletProfiles.filter { $0.id != activeWalletProfileId }
        walletProfiles = profiles

        if let nextProfile = profiles.first {
            activeWalletProfileId = nextProfile.id
        } else if !deletingLegacyProfile {
            activeWalletProfileId = legacyWalletProfileId
        }
    }

    func resetAllWalletProfiles() {
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefaults.synchronize()
        keychain.clear()
        pendingSetupWalletProfileId = nil
        pendingRestoreMnemonic = nil
        pendingSetupPassphrase = nil
        pendingWalletSecret = nil
    }

    private func clearActiveWalletData() {
        clearWalletData(profileId: activeWalletProfileId)
    }

    private func clearWalletData(profileId: String) {
        pendingRestoreMnemonic = nil
        pendingSetupPassphrase = nil
        pendingWalletSecret = nil

        for index in 0..<Self.maxMnemonicWordCount {
            keychain.delete(keychainKey("mnemonic.word.\(index)", profileId: profileId))
            userDefaults.removeObject(forKey: defaultsKey("mnemonic.word.\(index)", profileId: profileId))
        }

        keychain.delete(keychainKey("wallet.copayerId", profileId: profileId))
        keychain.delete(keychainKey("wallet.passphrase", profileId: profileId))
        keychain.delete(keychainKey("wallet.id", profileId: profileId))
        keychain.delete(keychainKey("wallet.name", profileId: profileId))
        keychain.delete(keychainKey("wallet.secret", profileId: profileId))
        userDefaults.removeObject(forKey: defaultsKey("wallet.amount", profileId: profileId))
        userDefaults.removeObject(forKey: defaultsKey("wallet.passphrase", profileId: profileId))
    }

    private func firstUsableWalletProfileId() -> String? {
        for profile in walletProfiles {
            if hasWalletRecoveryMaterial(profileId: profile.id) && pin != "" {
                return profile.id
            }
        }

        return firstWalletProfileIdWithMaterial()
    }

    private func firstWalletProfileIdWithMaterial() -> String? {
        for profile in walletProfiles {
            if hasWalletRecoveryMaterial(profileId: profile.id) {
                return profile.id
            }
        }

        return nil
    }

    // Store the wallet pin in the app key chain.
    var pin: String {
        get {
            return keychain.get("wallet.pin") ?? userDefaults.string(forKey: "wallet.pin") ?? ""
        }
        set {
            keychain.set(newValue, forKey: "wallet.pin")
            userDefaults.set(newValue, forKey: "wallet.pin")
        }
    }
    
    
    var copayerId: String? {
        get {
            return keychain.get(keychainKey("wallet.copayerId"))
        }
        set {
            if let copayerId = newValue {
                keychain.set(copayerId, forKey: keychainKey("wallet.copayerId"))
                upsertActiveWalletProfile(copayerId: copayerId)
            } else {
                keychain.delete(keychainKey("wallet.copayerId"))
            }
        }
    }
    var pinCount: Int {
        get {
            if self.pin.count > 0 {
                self.pinCount = self.pin.count
            }

            userDefaults.register(defaults: ["wallet.pinCount": 6])
            return userDefaults.integer(forKey: "wallet.pinCount")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.pinCount")
        }
    }

    // User wants to use tor or not.
    var useTor: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.useTor")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.useTor")
        }
    }
    
    // User wants to use NFC or not.
    var useNfc: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.useNfc")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.useNfc")
        }
    }

    // Store the selected wallet currency. Defaults to USD.
    var currency: String {
        get {
            return userDefaults.string(forKey: "wallet.currency") ?? "USD"
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.currency")
        }
    }

    var amount: NSNumber {
        get {
            return NSNumber(value: userDefaults.double(forKey: defaultsKey("wallet.amount")))
        }
        set {
            // Make sure wallet amount never gets less then zero.
            var correctNewValue = newValue.doubleValue
            if newValue.doubleValue < 0.0 {
                correctNewValue = 0.0
            }

            userDefaults.set(correctNewValue, forKey: defaultsKey("wallet.amount"))

            NotificationCenter.default.post(name: .didChangeWalletAmount, object: nil)
        }
    }

    var localAuthForWalletUnlock: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.localAuth.unlockWallet")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.localAuth.unlockWallet")
        }
    }

    var localAuthForSendingXvg: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.localAuth.sendingXvg")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.localAuth.sendingXvg")
        }
    }

    var mnemonic: [String]? {
        get {
            let profileId = pendingSetupWalletProfileId ?? activeWalletProfileId
            var mnemonic = [String]()

            for index in 0..<Self.maxMnemonicWordCount {
                guard let word = storedMnemonicWord(index: index, profileId: profileId) else {
                    break
                }
                mnemonic.append(word)
            }

            return isSupportedMnemonic(mnemonic) ? mnemonic : pendingRestoreMnemonic
        }
        set {
            guard let mnemonic = newValue else {
                pendingRestoreMnemonic = nil
                let profileId = setupWriteWalletProfileId
                for index in 0..<Self.maxMnemonicWordCount {
                    keychain.delete(keychainKey("mnemonic.word.\(index)", profileId: profileId))
                    userDefaults.removeObject(forKey: defaultsKey("mnemonic.word.\(index)", profileId: profileId))
                }
                return
            }

            pendingRestoreMnemonic = mnemonic
            let profileId = setupWriteWalletProfileId

            for index in 0..<Self.maxMnemonicWordCount {
                keychain.delete(keychainKey("mnemonic.word.\(index)", profileId: profileId))
                userDefaults.removeObject(forKey: defaultsKey("mnemonic.word.\(index)", profileId: profileId))
            }

            for (index, word) in mnemonic.prefix(Self.maxMnemonicWordCount).enumerated() {
                if saveSecureValue(word, forKey: keychainKey("mnemonic.word.\(index)", profileId: profileId)) {
                    userDefaults.removeObject(forKey: defaultsKey("mnemonic.word.\(index)", profileId: profileId))
                }
            }

            upsertSetupWalletProfile()
        }
    }

    var passphrase: String? {
        get {
            let profileId = pendingSetupWalletProfileId ?? activeWalletProfileId
            return passphrase(profileId: profileId)
        }
        set {
            if let passphrase = newValue {
                saveSetupPassphrase(passphrase)
            } else {
                pendingSetupPassphrase = nil
                keychain.delete(keychainKey("wallet.passphrase", profileId: setupWriteWalletProfileId))
                userDefaults.removeObject(forKey: defaultsKey("wallet.passphrase", profileId: setupWriteWalletProfileId))
            }
        }
    }

    var walletServiceUrl: String {
        get {
            return keychain.get("wallet.service.url") ?? Constants.bwsEndpoint
        }
        set {
            keychain.set(newValue, forKey: "wallet.service.url")
        }
    }

    var isWalletServiceUrlSet: Bool {
        return !(keychain.get("wallet.service.url")?.isEmpty ?? true)
    }

    var electrumXServers: [ElectrumXServer] {
        get {
            guard let data = userDefaults.data(forKey: electrumXServersKey),
                  let servers = try? JSONDecoder().decode([ElectrumXServer].self, from: data),
                  !servers.isEmpty else {
                return Self.defaultElectrumXServers
            }

            return servers.map { server in
                guard server.port == 443,
                      Self.defaultElectrumXServers.contains(where: { $0.host == server.host }) else {
                    return server
                }

                return ElectrumXServer(host: server.host, port: 50002, useTLS: server.useTLS)
            }
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }

            userDefaults.set(data, forKey: electrumXServersKey)
        }
    }

    func addElectrumXServer(_ server: ElectrumXServer) {
        var servers = electrumXServers
        guard !servers.contains(server) else {
            return
        }

        servers.append(server)
        electrumXServers = servers
    }

    func removeElectrumXServer(at index: Int) {
        var servers = electrumXServers
        guard servers.indices.contains(index) else {
            return
        }

        servers.remove(at: index)
        electrumXServers = servers
    }

    func resetElectrumXServers() {
        userDefaults.removeObject(forKey: electrumXServersKey)
        userDefaults.removeObject(forKey: activeElectrumXServerKey)
    }

    var activeElectrumXServer: ElectrumXServer {
        get {
            if let data = userDefaults.data(forKey: activeElectrumXServerKey),
               let server = try? JSONDecoder().decode(ElectrumXServer.self, from: data),
               electrumXServers.contains(server) {
                return server
            }

            return electrumXServers.first ?? Self.defaultElectrumXServers[0]
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }

            userDefaults.set(data, forKey: activeElectrumXServerKey)
        }
    }

    var orderedElectrumXServers: [ElectrumXServer] {
        let active = activeElectrumXServer
        var servers = electrumXServers.filter { $0 != active }
        servers.insert(active, at: 0)

        return servers
    }

    var walletId: String? {
        get {
            return keychain.get(keychainKey("wallet.id"))
        }
        set {
            if let walletId = newValue {
                keychain.set(walletId, forKey: keychainKey("wallet.id"))
                upsertActiveWalletProfile(walletId: walletId)
            } else {
                keychain.delete(keychainKey("wallet.id"))
            }
        }
    }

    var walletName: String? {
        get {
            return keychain.get(keychainKey("wallet.name"))
        }
        set {
            if let walletName = newValue {
                keychain.set(walletName, forKey: keychainKey("wallet.name"))
            } else {
                keychain.delete(keychainKey("wallet.name"))
            }
        }
    }

    var walletSecret: String? {
        get {
            return keychain.get(keychainKey("wallet.secret")) ?? pendingWalletSecret
        }
        set {
            if let walletSecret = newValue {
                pendingWalletSecret = walletSecret
                keychain.set(walletSecret, forKey: keychainKey("wallet.secret"))
            } else {
                pendingWalletSecret = nil
                keychain.delete(keychainKey("wallet.secret"))
            }
        }
    }

    var currentTheme: String? {
        get {
            return userDefaults.string(forKey: "currentTheme")
        }
        set {
            userDefaults.set(newValue, forKey: "currentTheme")

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didChangeTheme, object: nil)
            }
        }
    }

    /// Secure content setting (hidden xvg amount, etc.)
    var secureContent: Bool {
        get {
            return userDefaults.bool(forKey: "app.secureContent")
        }
        set {
            userDefaults.set(newValue, forKey: "app.secureContent")
            NotificationCenter.default.post(name: .didChangeSecureContent, object: nil)
        }
    }

    func reset() {
        deleteActiveWalletProfile()
    }

}
