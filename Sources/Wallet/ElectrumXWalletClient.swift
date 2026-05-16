import Foundation
import BitcoinKit
import CryptoSwift

final class ElectrumXWalletClient: WalletClientProtocol {
    enum ElectrumXWalletClientError: Error {
        case unsupportedOperation
        case addressDerivationFailed
    }

    private struct DerivedAddress {
        let index: Int
        let address: String
        let path: String
        let scriptPubKey: String
        let scriptHash: String
    }

    private let applicationRepository: ApplicationRepository
    private let credentials: Credentials
    private let electrumXClient: ElectrumXClient
    private let userDefaults = UserDefaults.standard
    private let minimumScanAddressCount = 1
    private let scanGapLimit = 0

    init(applicationRepository: ApplicationRepository, credentials: Credentials, electrumXClient: ElectrumXClient) {
        self.applicationRepository = applicationRepository
        self.credentials = credentials
        self.electrumXClient = electrumXClient
    }

    func createWallet(
        walletName: String,
        copayerName: String,
        m: Int,
        n: Int,
        options: Vws.WalletOptions?,
        completion: @escaping (Vws.WalletID?, Vws.WalletID.Error?, Error?) -> Void
    ) {
        completion(nil, nil, nil)
    }

    func joinWallet(
        walletIdentifier: String,
        completion: @escaping (Vws.WalletJoin?, Vws.WalletJoin.Error?, Error?) -> Void
    ) {
        completion(nil, nil, nil)
    }

    func openWallet(completion: @escaping (Vws.WalletStatus?, Vws.WalletStatus.Error?, Error?) -> Void) {
        completion(nil, nil, nil)
    }

    func currentCopayerId() -> String {
        return "electrumx"
    }

    func scanAddresses(completion: @escaping (_ error: Error?) -> Void) {
        completion(nil)
    }

    func createAddress(
        completion: @escaping (
            _ error: Error?,
            _ address: Vws.AddressInfo?,
            _ createAddressErrorResponse: Vws.CreateAddressError?
        ) -> Void
    ) {
        do {
            let nextIndex = receiveAddressIndex + 1
            let address = try derivedAddress(index: nextIndex)
            receiveAddressIndex = nextIndex
            completion(nil, addressInfo(for: address), nil)
        } catch {
            completion(error, nil, nil)
        }
    }

    func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: Vws.WalletBalanceInfo?) -> Void) {
        do {
            let addresses = try scanAddresses()
            let lock = NSLock()
            var confirmed: Int64 = 0
            var unconfirmed: Int64 = 0
            var byAddress = [Vws.AddressBalance]()
            var returnedError: Error?

            scanBalance(addresses: addresses, index: 0) { address, result in
                guard let address = address else {
                    let total = Double(confirmed + unconfirmed)
                    print("ElectrumX balance scanned=\(addresses.count) total=\(total)")
                    let balance = Vws.WalletBalanceInfo(
                        totalAmount: total,
                        lockedAmount: 0,
                        totalConfirmedAmount: Double(confirmed),
                        lockedConfirmedAmount: 0,
                        availableAmount: total,
                        availableConfirmedAmount: Double(confirmed),
                        byAddress: byAddress
                    )
                    DispatchQueue.main.async {
                        completion(returnedError, balance)
                    }
                    return
                }

                switch result {
                case .success(let json):
                    let result = json["result"] as? [String: Any]
                    let addressConfirmed = self.int64Value(result?["confirmed"]) ?? 0
                    let addressUnconfirmed = self.int64Value(result?["unconfirmed"]) ?? 0

                    lock.lock()
                    confirmed += addressConfirmed
                    unconfirmed += addressUnconfirmed
                    if addressConfirmed + addressUnconfirmed > 0 {
                        print("ElectrumX balance \(address.path) \(address.address) confirmed=\(addressConfirmed) unconfirmed=\(addressUnconfirmed)")
                        byAddress.append(
                            Vws.AddressBalance(
                                address: address.address,
                                path: address.path,
                                amount: Double(addressConfirmed + addressUnconfirmed)
                            )
                        )
                    }
                    lock.unlock()
                case .failure(let error):
                    print("ElectrumX balance failed \(address.path) \(address.address): \(error.localizedDescription)")
                    lock.lock()
                    returnedError = returnedError ?? error
                    lock.unlock()
                }
            }
        } catch {
            completion(error, nil)
        }
    }

    private func scanBalance(
        addresses: [DerivedAddress],
        index: Int,
        update: @escaping (DerivedAddress?, Result<[String: Any], Error>) -> Void
    ) {
        guard addresses.indices.contains(index) else {
            update(nil, .success([:]))
            return
        }

        let address = addresses[index]
        electrumXClient.request(
            method: "blockchain.scripthash.get_balance",
            params: [address.scriptHash]
        ) { result in
            update(address, result)
            self.scanBalance(addresses: addresses, index: index + 1, update: update)
        }
    }

    func getMainAddresses(
        options: Vws.WalletAddressesOptions?,
        completion: @escaping (_ error: Error?, _ addresses: [Vws.AddressInfo]) -> Void
    ) {
        do {
            let current = try derivedAddress(index: receiveAddressIndex)
            print("ElectrumX receive \(current.path) \(current.address) scripthash=\(current.scriptHash)")
            completion(nil, [addressInfo(for: current)])
        } catch {
            completion(error, [])
        }
    }

    func getTxHistory(
        skip: Int?,
        limit: Int?,
        completion: @escaping ([Vws.TxHistory], Error?) -> Void
    ) {
        do {
            let addresses = try scanAddresses()
            let ownScriptAddresses = Dictionary(uniqueKeysWithValues: addresses.map { ($0.scriptPubKey, $0.address) })

            scanHistory(
                addresses: addresses,
                index: 0,
                ownScriptAddresses: ownScriptAddresses,
                accumulated: [],
                returnedError: nil
            ) { transactions, returnedError in
                var seen = Set<String>()
                let unique = transactions.filter { tx in
                    if seen.contains(tx.txid) {
                        return false
                    }

                    seen.insert(tx.txid)
                    return true
                }

                print("ElectrumX history scanned=\(addresses.count) uniqueTxs=\(unique.count)")
                DispatchQueue.main.async {
                    completion(unique.sorted { $0.sortBy(txHistory: $1) }, returnedError)
                }
            }
        } catch {
            completion([], error)
        }
    }

    private func scanHistory(
        addresses: [DerivedAddress],
        index: Int,
        ownScriptAddresses: [String: String],
        accumulated: [Vws.TxHistory],
        returnedError: Error?,
        completion: @escaping ([Vws.TxHistory], Error?) -> Void
    ) {
        guard addresses.indices.contains(index) else {
            completion(accumulated, returnedError)
            return
        }

        let address = addresses[index]
        electrumXClient.request(
            method: "blockchain.scripthash.get_history",
            params: [address.scriptHash]
        ) { result in
            switch result {
            case .success(let json):
                let history = json["result"] as? [[String: Any]] ?? []
                if !history.isEmpty {
                    print("ElectrumX history \(address.path) \(address.address) count=\(history.count)")
                }

                self.txHistories(
                    from: history,
                    index: 0,
                    address: address.address,
                    ownScriptAddresses: ownScriptAddresses,
                    accumulated: []
                ) { txs in
                    self.scanHistory(
                        addresses: addresses,
                        index: index + 1,
                        ownScriptAddresses: ownScriptAddresses,
                        accumulated: accumulated + txs,
                        returnedError: returnedError,
                        completion: completion
                    )
                }
            case .failure(let error):
                print("ElectrumX history failed \(address.path) \(address.address): \(error.localizedDescription)")
                self.scanHistory(
                    addresses: addresses,
                    index: index + 1,
                    ownScriptAddresses: ownScriptAddresses,
                    accumulated: accumulated,
                    returnedError: returnedError ?? error,
                    completion: completion
                )
            }
        }
    }

    private func txHistories(
        from history: [[String: Any]],
        index: Int,
        address: String,
        ownScriptAddresses: [String: String],
        accumulated: [Vws.TxHistory],
        completion: @escaping ([Vws.TxHistory]) -> Void
    ) {
        guard history.indices.contains(index) else {
            completion(accumulated)
            return
        }

        guard let txid = history[index]["tx_hash"] as? String else {
            txHistories(
                from: history,
                index: index + 1,
                address: address,
                ownScriptAddresses: ownScriptAddresses,
                accumulated: accumulated,
                completion: completion
            )
            return
        }

        electrumXClient.request(
            method: "blockchain.transaction.get",
            params: [txid, true]
        ) { result in
            var next = accumulated
            switch result {
            case .success(let json):
                if let tx = self.txHistory(
                    from: history[index],
                    detail: json["result"] as? [String: Any],
                    address: address,
                    ownScriptAddresses: ownScriptAddresses
                ) {
                    next.append(tx)
                }
            case .failure(let error):
                print("ElectrumX transaction detail failed \(txid): \(error.localizedDescription)")
                if let tx = self.txHistory(
                    from: history[index],
                    detail: nil,
                    address: address,
                    ownScriptAddresses: ownScriptAddresses
                ) {
                    next.append(tx)
                }
            }

            self.txHistories(
                from: history,
                index: index + 1,
                address: address,
                ownScriptAddresses: ownScriptAddresses,
                accumulated: next,
                completion: completion
            )
        }
    }

    func getUnspentOutputs(address: String?, completion: @escaping ([Vws.UnspentOutput], Error?) -> Void) {
        completion([], ElectrumXWalletClientError.unsupportedOperation)
    }

    func getSendMaxInfo(completion: @escaping (Vws.SendMaxInfo?, Error?) -> Void) {
        completion(nil, ElectrumXWalletClientError.unsupportedOperation)
    }

    func createTxProposal(
        proposal: Vws.TxProposal,
        completion: @escaping (
            _ txp: Vws.TxProposalResponse?,
            _ errorResponse: Vws.TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    ) {
        completion(nil, nil, ElectrumXWalletClientError.unsupportedOperation)
    }

    func publishTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping (
            _ txp: Vws.TxProposalResponse?,
            _ errorResponse: Vws.TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    ) {
        completion(nil, nil, ElectrumXWalletClientError.unsupportedOperation)
    }

    func signTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping (
            _ txp: Vws.TxProposalResponse?,
            _ errorResponse: Vws.TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    ) {
        completion(nil, nil, ElectrumXWalletClientError.unsupportedOperation)
    }

    func broadcastTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping (
            _ txp: Vws.TxProposalResponse?,
            _ errorResponse: Vws.TxProposalErrorResponse?,
            _ error: Error?
        ) -> Void
    ) {
        completion(nil, nil, ElectrumXWalletClientError.unsupportedOperation)
    }

    func rejectTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ error: Error?) -> Void) {
        completion(nil)
    }

    func deleteTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ error: Error?) -> Void) {
        completion(nil)
    }

    func getTxProposals(completion: @escaping (_ txps: [Vws.TxProposalResponse], _ error: Error?) -> Void) {
        completion([], nil)
    }

    func resetServiceUrl(baseUrl: String) {}

    func watchRequestCredentialsForMethodPath(path: String) throws -> WatchRequestCredentials {
        throw ElectrumXWalletClientError.unsupportedOperation
    }

    private var receiveAddressIndex: Int {
        get {
            return userDefaults.integer(forKey: receiveAddressIndexKey)
        }
        set {
            userDefaults.set(newValue, forKey: receiveAddressIndexKey)
        }
    }

    private var receiveAddressIndexKey: String {
        return "wallet.electrumx.receiveIndex.\(applicationRepository.activeWalletProfileId)"
    }

    private func scanAddresses() throws -> [DerivedAddress] {
        let count = max(minimumScanAddressCount, receiveAddressIndex + scanGapLimit + 1)
        return try (0..<count).map { try derivedAddress(index: $0) }
    }

    private func derivedAddress(index: Int) throws -> DerivedAddress {
        let key = try credentials.bip44PrivateKey
            .derived(at: 0, hardened: false)
            .derived(at: UInt32(index), hardened: false)
        let privateKey = key.privateKey()
        let publicKey = privateKey.publicKey()
        let address = publicKey.toBitcoinAddress().description
        let scriptPubKey = p2pkhScriptPubKey(publicKey: publicKey)
        let scriptHash = electrumScriptHash(scriptPubKey: scriptPubKey)

        return DerivedAddress(
            index: index,
            address: address,
            path: "m/44'/77'/0'/0/\(index)",
            scriptPubKey: scriptPubKey.toHexString(),
            scriptHash: scriptHash
        )
    }

    private func addressInfo(for derivedAddress: DerivedAddress) -> Vws.AddressInfo {
        return Vws.AddressInfo(
            network: "livenet",
            path: derivedAddress.path,
            isChange: false,
            coin: "xvg",
            _id: nil,
            type: "P2PKH",
            createdOn: Int(Date().timeIntervalSince1970),
            version: "1.0.0",
            publicKeys: [],
            address: derivedAddress.address,
            walletId: "electrumx-\(applicationRepository.activeWalletProfileId)",
            hasActivity: nil
        )
    }

    private func p2pkhScriptPubKey(publicKey: PublicKey) -> Data {
        var script = Data([0x76, 0xa9, 0x14])
        script.append(publicKey.pubkeyHash)
        script.append(contentsOf: [0x88, 0xac])

        return script
    }

    private func electrumScriptHash(scriptPubKey: Data) -> String {
        return Data(Crypto.sha256(scriptPubKey).reversed()).toHexString()
    }

    private func txHistory(
        from item: [String: Any],
        detail: [String: Any]?,
        address: String,
        ownScriptAddresses: [String: String]
    ) -> Vws.TxHistory? {
        guard let txid = item["tx_hash"] as? String else {
            return nil
        }

        let height = int64Value(item["height"]) ?? 0
        let confirmations = int64Value(detail?["confirmations"]) ?? (height > 0 ? 1 : 0)
        let time = int64Value(detail?["time"]) ?? int64Value(detail?["blocktime"]) ?? 0
        var amount: Int64 = 0
        var outputs = [Vws.InputOutput]()

        for vout in detail?["vout"] as? [[String: Any]] ?? [] {
            guard let scriptPubKey = vout["scriptPubKey"] as? [String: Any],
                  let scriptHex = scriptPubKey["hex"] as? String,
                  let outputAddress = ownScriptAddresses[scriptHex] else {
                continue
            }

            let outputAmount = satoshis(fromXvgValue: vout["value"])
            amount += outputAmount
            outputs.append(Vws.InputOutput(amount: Int(outputAmount), address: outputAddress, isMine: true))
        }

        if outputs.isEmpty {
            outputs.append(Vws.InputOutput(amount: Int(amount), address: address, isMine: true))
        }

        print("ElectrumX tx \(txid) amount=\(amount)")

        return Vws.TxHistory(
            txid: txid,
            action: "received",
            amount: amount,
            fees: nil,
            time: time,
            confirmations: confirmations,
            blockheight: height,
            feePerKb: nil,
            inputs: nil,
            outputs: outputs,
            savedAddress: address,
            createdOn: nil,
            message: nil,
            addressTo: nil
        )
    }

    private func satoshis(fromXvgValue value: Any?) -> Int64 {
        if let double = value as? Double {
            return Int64((double * Constants.satoshiDivider).rounded())
        }

        if let int = value as? Int {
            return Int64(Double(int) * Constants.satoshiDivider)
        }

        if let string = value as? String, let double = Double(string) {
            return Int64((double * Constants.satoshiDivider).rounded())
        }

        return 0
    }

    private func int64Value(_ value: Any?) -> Int64? {
        if let int = value as? Int {
            return Int64(int)
        }

        if let int64 = value as? Int64 {
            return int64
        }

        if let double = value as? Double {
            return Int64(double)
        }

        if let string = value as? String {
            return Int64(string)
        }

        return nil
    }
}

extension ElectrumXWalletClient.ElectrumXWalletClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unsupportedOperation:
            return "Sending from 18-word ElectrumX wallets is not implemented yet."
        case .addressDerivationFailed:
            return "Could not derive an ElectrumX wallet address."
        }
    }
}

final class RoutingWalletClient: WalletClientProtocol {
    private let applicationRepository: ApplicationRepository
    private let vwsClient: WalletClientProtocol
    private let electrumXClient: ElectrumXClient

    init(applicationRepository: ApplicationRepository, vwsClient: WalletClientProtocol, electrumXClient: ElectrumXClient) {
        self.applicationRepository = applicationRepository
        self.vwsClient = vwsClient
        self.electrumXClient = electrumXClient
    }

    private var activeClient: WalletClientProtocol {
        guard let mnemonic = applicationRepository.mnemonic,
              !applicationRepository.requiresSetupPassphrase(mnemonic: mnemonic) else {
            print("RoutingWalletClient active=vws")
            return vwsClient
        }

        print("RoutingWalletClient active=electrumx words=\(mnemonic.count)")
        let credentials = Credentials(mnemonic: mnemonic, passphrase: applicationRepository.passphrase ?? "")
        return ElectrumXWalletClient(
            applicationRepository: applicationRepository,
            credentials: credentials,
            electrumXClient: electrumXClient
        )
    }

    func createWallet(walletName: String, copayerName: String, m: Int, n: Int, options: Vws.WalletOptions?, completion: @escaping (Vws.WalletID?, Vws.WalletID.Error?, Error?) -> Void) {
        activeClient.createWallet(walletName: walletName, copayerName: copayerName, m: m, n: n, options: options, completion: completion)
    }

    func joinWallet(walletIdentifier: String, completion: @escaping (Vws.WalletJoin?, Vws.WalletJoin.Error?, Error?) -> Void) {
        activeClient.joinWallet(walletIdentifier: walletIdentifier, completion: completion)
    }

    func openWallet(completion: @escaping (Vws.WalletStatus?, Vws.WalletStatus.Error?, Error?) -> Void) {
        activeClient.openWallet(completion: completion)
    }

    func currentCopayerId() -> String { activeClient.currentCopayerId() }
    func scanAddresses(completion: @escaping (_ error: Error?) -> Void) { activeClient.scanAddresses(completion: completion) }
    func createAddress(completion: @escaping (_ error: Error?, _ address: Vws.AddressInfo?, _ createAddressErrorResponse: Vws.CreateAddressError?) -> Void) { activeClient.createAddress(completion: completion) }
    func getBalance(completion: @escaping (_ error: Error?, _ balanceInfo: Vws.WalletBalanceInfo?) -> Void) { activeClient.getBalance(completion: completion) }
    func getMainAddresses(options: Vws.WalletAddressesOptions?, completion: @escaping (_ error: Error?, _ addresses: [Vws.AddressInfo]) -> Void) { activeClient.getMainAddresses(options: options, completion: completion) }
    func getTxHistory(skip: Int?, limit: Int?, completion: @escaping ([Vws.TxHistory], Error?) -> Void) { activeClient.getTxHistory(skip: skip, limit: limit, completion: completion) }
    func getUnspentOutputs(address: String?, completion: @escaping ([Vws.UnspentOutput], Error?) -> Void) { activeClient.getUnspentOutputs(address: address, completion: completion) }
    func getSendMaxInfo(completion: @escaping (Vws.SendMaxInfo?, Error?) -> Void) { activeClient.getSendMaxInfo(completion: completion) }
    func createTxProposal(proposal: Vws.TxProposal, completion: @escaping (_ txp: Vws.TxProposalResponse?, _ errorResponse: Vws.TxProposalErrorResponse?, _ error: Error?) -> Void) { activeClient.createTxProposal(proposal: proposal, completion: completion) }
    func publishTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ txp: Vws.TxProposalResponse?, _ errorResponse: Vws.TxProposalErrorResponse?, _ error: Error?) -> Void) { activeClient.publishTxProposal(txp: txp, completion: completion) }
    func signTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ txp: Vws.TxProposalResponse?, _ errorResponse: Vws.TxProposalErrorResponse?, _ error: Error?) -> Void) { activeClient.signTxProposal(txp: txp, completion: completion) }
    func broadcastTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ txp: Vws.TxProposalResponse?, _ errorResponse: Vws.TxProposalErrorResponse?, _ error: Error?) -> Void) { activeClient.broadcastTxProposal(txp: txp, completion: completion) }
    func rejectTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ error: Error?) -> Void) { activeClient.rejectTxProposal(txp: txp, completion: completion) }
    func deleteTxProposal(txp: Vws.TxProposalResponse, completion: @escaping (_ error: Error?) -> Void) { activeClient.deleteTxProposal(txp: txp, completion: completion) }
    func getTxProposals(completion: @escaping (_ txps: [Vws.TxProposalResponse], _ error: Error?) -> Void) { activeClient.getTxProposals(completion: completion) }
    func resetServiceUrl(baseUrl: String) { vwsClient.resetServiceUrl(baseUrl: baseUrl) }
    func watchRequestCredentialsForMethodPath(path: String) throws -> WatchRequestCredentials { try activeClient.watchRequestCredentialsForMethodPath(path: path) }
}
