import Foundation
import BitcoinKit
import CryptoSwift
import secp256k1

final class ElectrumXWalletClient: WalletClientProtocol {
    enum ElectrumXWalletClientError: Error {
        case unsupportedOperation
        case addressDerivationFailed
        case invalidDestinationAddress(String)
        case insufficientFunds
        case noSpendableOutputs(total: UInt64)
        case missingSignedTransaction
        case noSigningKeyFound(String)
        case localScriptVerificationFailed(String)
    }

    private struct DerivedAddress {
        let index: Int
        let address: String
        let path: String
        let scriptPubKey: String
        let scriptHash: String
        let publicKey: String
        let privateKey: PrivateKey
        let isChange: Bool
    }

    private struct ElectrumXUnsignedTransaction {
        let tx: Transaction
        let utxos: [UnspentTransaction]
        let inputs: [Vws.UnspentOutput]
        let keys: [String: PrivateKey]
        let timestamp: UInt32
    }

    private let applicationRepository: ApplicationRepository
    private let credentials: Credentials
    private let electrumXClient: ElectrumXClient
    private let userDefaults = UserDefaults.standard
    private let minimumScanAddressCount = 1
    private let scanGapLimit = 0
    private let dustThreshold: UInt64 = 1_000
    private let feePerKb: UInt64 = 100_000
    private let unspentOutputCacheTTL: TimeInterval = 30
    private var unspentOutputCache: (profileId: String, createdAt: Date, outputs: [Vws.UnspentOutput])?
    private static var signedTransactions = [String: String]()
    typealias TxProposalCompletion = (
        _ txp: Vws.TxProposalResponse?,
        _ errorResponse: Vws.TxProposalErrorResponse?,
        _ error: Error?
    ) -> Void

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

            scanBalance(addresses: addresses) { address, result in
                guard let address = address else {
                    let total = Double(confirmed + unconfirmed)
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
        update: @escaping (DerivedAddress?, Result<[String: Any], Error>) -> Void
    ) {
        guard !addresses.isEmpty else {
            update(nil, .success([:]))
            return
        }

        let group = DispatchGroup()
        for address in addresses {
            group.enter()
            electrumXClient.request(
                method: "blockchain.scripthash.get_balance",
                params: [address.scriptHash]
            ) { result in
                update(address, result)
                group.leave()
            }
        }

        group.notify(queue: .global(qos: .userInitiated)) {
            update(nil, .success([:]))
        }
    }

    func getMainAddresses(
        options: Vws.WalletAddressesOptions?,
        completion: @escaping (_ error: Error?, _ addresses: [Vws.AddressInfo]) -> Void
    ) {
        do {
            let current = try derivedAddress(index: receiveAddressIndex)
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
            case .failure:
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
        let profileId = applicationRepository.activeWalletProfileId
        if let cache = unspentOutputCache,
           cache.profileId == profileId,
           Date().timeIntervalSince(cache.createdAt) < unspentOutputCacheTTL {
            completion(cache.outputs, nil)
            return
        }

        do {
            let addresses = try scanAddresses()
            collectUnspentOutputs(addresses: addresses) { outputs, error in
                if error == nil {
                    self.unspentOutputCache = (profileId: profileId, createdAt: Date(), outputs: outputs)
                }
                DispatchQueue.main.async {
                    completion(outputs, error)
                }
            }
        } catch {
            completion([], error)
        }
    }

    func getSendMaxInfo(completion: @escaping (Vws.SendMaxInfo?, Error?) -> Void) {
        getUnspentOutputs(address: nil) { outputs, error in
            guard error == nil else {
                return completion(nil, error)
            }

            let total = outputs.reduce(UInt64(0)) { $0 + $1.satoshis }
            let fee = self.estimatedFee(inputCount: outputs.count, outputCount: 1)
            let amount = total > fee ? total - fee : 0
            completion(
                Vws.SendMaxInfo(
                    size: UInt64(10 + (outputs.count * 180) + 34),
                    amount: amount,
                    fee: fee,
                    feePerKb: self.feePerKb,
                    utxosBelowFee: 0,
                    amountBelowFee: 0,
                    utxosAboveMaxSize: 0,
                    amountAboveMaxSize: 0
                ),
                nil
            )
        }
    }

    func createTxProposal(
        proposal: Vws.TxProposal,
        completion: @escaping TxProposalCompletion
    ) {
        do {
            let destination = try createAddress(proposal.address)
            let amount = UInt64((proposal.amount.doubleValue * Constants.satoshiDivider).rounded())

            getUnspentOutputs(address: nil) { outputs, error in
                if let error = error {
                    return self.completeTxProposal(completion, txp: nil, errorResponse: nil, error: error)
                }

                do {
                    let selected = try self.selectInputs(from: outputs, amount: amount)
                    let fee = self.estimatedFee(inputCount: selected.count, outputCount: 2)
                    let total = selected.reduce(UInt64(0)) { $0 + $1.satoshis }
                    guard total >= amount + fee else {
                        throw ElectrumXWalletClientError.insufficientFunds
                    }

                    let change = total - amount - fee
                    let changeAddress = try self.nextChangeAddress()
                    let output = Vws.TxOutput(
                        amount: Int64(amount),
                        message: nil,
                        encryptedMessage: nil,
                        toAddress: destination.description,
                        ephemeralPrivKey: nil,
                        stealth: false
                    )
                    let txp = Vws.TxProposalResponse(
                        createdOn: UInt32(Date().timeIntervalSince1970),
                        coin: "xvg",
                        id: UUID().uuidString,
                        network: "livenet",
                        message: proposal.message.isEmpty ? nil : proposal.message,
                        inputs: selected,
                        fee: fee,
                        status: "pending",
                        creatorId: "electrumx",
                        walletN: 1,
                        walletM: 1,
                        outputs: [output],
                        amount: amount,
                        changeAddress: self.changeAddressInfo(for: changeAddress),
                        walletId: "electrumx-\(self.applicationRepository.activeWalletProfileId)",
                        requiredSignatures: 1,
                        version: 1,
                        excludeUnconfirmedUtxos: false,
                        addressType: "P2PKH",
                        requiredRejections: 1,
                        outputOrder: change > self.dustThreshold ? [0, 1] : [0],
                        inputPaths: selected.map { $0.path }
                    )
                    self.completeTxProposal(completion, txp: txp, errorResponse: nil, error: nil)
                } catch {
                    self.completeTxProposal(completion, txp: nil, errorResponse: nil, error: error)
                }
            }
        } catch {
            completeTxProposal(completion, txp: nil, errorResponse: nil, error: ElectrumXWalletClientError.invalidDestinationAddress(proposal.address))
        }
    }

    func publishTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping TxProposalCompletion
    ) {
        completeTxProposal(completion, txp: txp, errorResponse: nil, error: nil)
    }

    func signTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping TxProposalCompletion
    ) {
        do {
            let unsignedTx = try getUnsignedTx(txp: txp)
            let signedTx = try signTransaction(unsignedTx)
            Self.signedTransactions[txp.id] = serializeTransaction(signedTx, timestamp: unsignedTx.timestamp).hex
            completeTxProposal(completion, txp: acceptedTxProposal(txp), errorResponse: nil, error: nil)
        } catch {
            completeTxProposal(completion, txp: nil, errorResponse: nil, error: error)
        }
    }

    func broadcastTxProposal(
        txp: Vws.TxProposalResponse,
        completion: @escaping TxProposalCompletion
    ) {
        guard let rawTx = Self.signedTransactions[txp.id] else {
            return completeTxProposal(completion, txp: nil, errorResponse: nil, error: ElectrumXWalletClientError.missingSignedTransaction)
        }

        electrumXClient.request(
            method: "blockchain.transaction.broadcast",
            params: [rawTx]
        ) { result in
            switch result {
            case .success:
                self.unspentOutputCache = nil
                Self.signedTransactions.removeValue(forKey: txp.id)
                self.completeTxProposal(completion, txp: self.broadcastedTxProposal(txp), errorResponse: nil, error: nil)
            case .failure(let error):
                self.completeTxProposal(completion, txp: nil, errorResponse: nil, error: error)
            }
        }
    }

    private func completeTxProposal(
        _ completion: @escaping TxProposalCompletion,
        txp: Vws.TxProposalResponse?,
        errorResponse: Vws.TxProposalErrorResponse?,
        error: Error?
    ) {
        if Thread.isMainThread {
            completion(txp, errorResponse, error)
        } else {
            DispatchQueue.main.async {
                completion(txp, errorResponse, error)
            }
        }
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

    private var changeAddressIndex: Int {
        get {
            return userDefaults.integer(forKey: changeAddressIndexKey)
        }
        set {
            userDefaults.set(newValue, forKey: changeAddressIndexKey)
        }
    }

    private var changeAddressIndexKey: String {
        return "wallet.electrumx.changeIndex.\(applicationRepository.activeWalletProfileId)"
    }

    private func scanAddresses() throws -> [DerivedAddress] {
        let receiveCount = max(minimumScanAddressCount, receiveAddressIndex + scanGapLimit + 1)
        let changeCount = max(minimumScanAddressCount, changeAddressIndex + scanGapLimit + 1)
        let receive = try (0..<receiveCount).map { index in
            try derivedAddress(chain: 0, index: index)
        }
        let change = try (0..<changeCount).map { index in
            try derivedAddress(chain: 1, index: index)
        }
        return receive + change
    }

    private func derivedAddress(index: Int) throws -> DerivedAddress {
        return try derivedAddress(chain: 0, index: index)
    }

    private func derivedAddress(chain: Int, index: Int) throws -> DerivedAddress {
        let key = try credentials.bip44PrivateKey
            .derived(at: UInt32(chain), hardened: false)
            .derived(at: UInt32(index), hardened: false)
        let privateKey = key.privateKey()
        let publicKey = privateKey.publicKey()
        let pubkeyHash = standardHash160(publicKey.data)
        let address = try BitcoinAddress(data: pubkeyHash, hashType: .pubkeyHash, network: .mainnetXVG).description
        let scriptPubKey = p2pkhScriptPubKey(pubkeyHash: pubkeyHash)
        let scriptHash = electrumScriptHash(scriptPubKey: scriptPubKey)

        return DerivedAddress(
            index: index,
            address: address,
            path: "m/44'/77'/0'/\(chain)/\(index)",
            scriptPubKey: scriptPubKey.toHexString(),
            scriptHash: scriptHash,
            publicKey: publicKey.description,
            privateKey: privateKey,
            isChange: chain == 1
        )
    }

    private func addressInfo(for derivedAddress: DerivedAddress) -> Vws.AddressInfo {
        return Vws.AddressInfo(
            network: "livenet",
            path: derivedAddress.path,
            isChange: derivedAddress.isChange,
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

    private func p2pkhScriptPubKey(pubkeyHash: Data) -> Data {
        var script = Data([0x76, 0xa9, 0x14])
        script.append(pubkeyHash)
        script.append(contentsOf: [0x88, 0xac])

        return script
    }

    private func collectUnspentOutputs(
        addresses: [DerivedAddress],
        completion: @escaping ([Vws.UnspentOutput], Error?) -> Void
    ) {
        guard !addresses.isEmpty else {
            completion([], nil)
            return
        }

        let lock = NSLock()
        let group = DispatchGroup()
        var accumulated = [Vws.UnspentOutput]()
        var returnedError: Error?

        for address in addresses {
            group.enter()
            electrumXClient.request(
                method: "blockchain.scripthash.listunspent",
                params: [address.scriptHash]
            ) { result in
                switch result {
                case .success(let json):
                    let unspent = (json["result"] as? [[String: Any]] ?? []).compactMap { item -> Vws.UnspentOutput? in
                        guard let txid = item["tx_hash"] as? String,
                              let vout = self.uint32Value(item["tx_pos"]),
                              let value = self.uint64Value(item["value"]) else {
                            return nil
                        }

                        return Vws.UnspentOutput(
                            address: address.address,
                            confirmations: (self.int64Value(item["height"]) ?? 0) > 0 ? 1 : 0,
                            satoshis: value,
                            scriptPubKey: address.scriptPubKey,
                            txID: txid,
                            vout: vout,
                            publicKeys: [address.publicKey],
                            path: address.path,
                            locked: false
                        )
                    }

                    lock.lock()
                    accumulated.append(contentsOf: unspent)
                    lock.unlock()
                case .failure(let error):
                    lock.lock()
                    returnedError = returnedError ?? error
                    lock.unlock()
                }

                group.leave()
            }
        }

        group.notify(queue: .global(qos: .userInitiated)) {
            let sorted = accumulated.sorted {
                if $0.satoshis == $1.satoshis {
                    return $0.txID < $1.txID
                }
                return $0.satoshis > $1.satoshis
            }
            completion(sorted, returnedError)
        }
    }

    private func selectInputs(from outputs: [Vws.UnspentOutput], amount: UInt64) throws -> [Vws.UnspentOutput] {
        var selected = [Vws.UnspentOutput]()
        var total: UInt64 = 0
        let keys = try scanAddresses().map { $0.privateKey }
        let spendableOutputs = outputs.filter { output in
            guard let pubkeyHash = try? Script.getPublicKeyHash(from: output.asUnspentTransaction().output.lockingScript) else {
                return false
            }

            return keys.contains { signingKey(from: $0, matching: pubkeyHash) != nil }
        }
        let discoveredTotal = outputs.reduce(UInt64(0)) { $0 + $1.satoshis }
        if discoveredTotal > 0 && spendableOutputs.isEmpty {
            throw ElectrumXWalletClientError.noSpendableOutputs(total: discoveredTotal)
        }

        for output in spendableOutputs.sorted(by: { $0.satoshis > $1.satoshis }) where !output.locked {
            selected.append(output)
            total += output.satoshis
            let fee = estimatedFee(inputCount: selected.count, outputCount: 2)
            if total >= amount + fee {
                return selected
            }
        }

        throw ElectrumXWalletClientError.insufficientFunds
    }

    private func estimatedFee(inputCount: Int, outputCount: Int) -> UInt64 {
        let size = 10 + (inputCount * 180) + (outputCount * 34)
        return UInt64(ceil(Double(size) / 1000.0)) * feePerKb
    }

    private func nextChangeAddress() throws -> DerivedAddress {
        let index = changeAddressIndex
        let address = try derivedAddress(chain: 1, index: index)
        changeAddressIndex = index + 1
        return address
    }

    private func changeAddressInfo(for derivedAddress: DerivedAddress) -> Vws.TxChangeAddress {
        return Vws.TxChangeAddress(
            isChange: true,
            coin: "xvg",
            publicKeys: [derivedAddress.publicKey],
            type: "P2PKH",
            version: "1.0.0",
            path: derivedAddress.path,
            walletId: "electrumx-\(applicationRepository.activeWalletProfileId)",
            createdOn: Int64(Date().timeIntervalSince1970),
            network: "livenet",
            address: derivedAddress.address,
            _id: derivedAddress.address
        )
    }

    private func getUnsignedTx(txp: Vws.TxProposalResponse) throws -> ElectrumXUnsignedTransaction {
        guard let output = txp.outputs.first else {
            throw ElectrumXWalletClientError.unsupportedOperation
        }

        let destinationAddress = try createAddress(output.toAddress)
        let changeAddress = try createAddress(txp.changeAddress.address)
        let destinationScript = try lockingScript(for: destinationAddress)
        let changeScript = try lockingScript(for: changeAddress)
        let unspentTransactions = try txp.inputs.map { try $0.asUnspentTransaction() }
        let unsignedInputs = try txp.inputs.map { try $0.asInputTransaction() }
        let total = unspentTransactions.reduce(UInt64(0)) { $0 + $1.output.value }
        let change = total > txp.amount + txp.fee ? total - txp.amount - txp.fee : 0

        var outputs = [
            TransactionOutput(value: txp.amount, lockingScript: destinationScript.data)
        ]

        if change > dustThreshold {
            outputs.append(TransactionOutput(value: change, lockingScript: changeScript.data))
        }

        outputs = outputs.sortByIndices(indices: txp.outputOrder.map { Int($0) })

        let tx = Transaction(
            version: 1,
            inputs: unsignedInputs,
            outputs: outputs,
            lockTime: 0
        )

        let keys = signingKeysByPath(from: try scanAddresses())
        return ElectrumXUnsignedTransaction(
            tx: tx,
            utxos: unspentTransactions,
            inputs: txp.inputs,
            keys: keys,
            timestamp: txp.createdOn ?? UInt32(Date().timeIntervalSince1970)
        )
    }

    private func signingKeysByPath(from addresses: [DerivedAddress]) -> [String: PrivateKey] {
        var keys = [String: PrivateKey]()
        for address in addresses {
            keys[address.path] = keys[address.path] ?? address.privateKey
        }
        return keys
    }

    private func signTransaction(_ unsignedTx: ElectrumXUnsignedTransaction) throws -> Transaction {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(
                version: unsignedTx.tx.version,
                inputs: inputsToSign,
                outputs: unsignedTx.tx.outputs,
                lockTime: unsignedTx.tx.lockTime
            )
        }

        for (index, utxo) in unsignedTx.utxos.enumerated() {
            let input = unsignedTx.inputs[index]
            let pubkeyHash = Script.getPublicKeyHash(from: utxo.output.lockingScript)
            let key = unsignedTx.keys[input.path] ?? unsignedTx.keys.values.first {
                signingKey(from: $0, matching: pubkeyHash) != nil
            }

            guard let key = key else {
                throw ElectrumXWalletClientError.noSigningKeyFound(input.path)
            }

            guard let scriptKey = signingKey(from: key, matching: pubkeyHash) else {
                throw ElectrumXWalletClientError.noSigningKeyFound(input.path)
            }

            let sighash = signatureHash(
                transactionToSign,
                timestamp: unsignedTx.timestamp,
                for: utxo.output,
                inputIndex: index,
                hashType: SighashType.BTC.ALL
            )
            let signature = try convertCompactToDER(signDigest(sighash, privateKey: scriptKey))
            let unlockingScript = Script.buildPublicKeyUnlockingScript(
                signature: signature,
                pubkey: scriptKey.publicKey(),
                hashType: SighashType.BTC.ALL
            )
            let txin = inputsToSign[index]
            inputsToSign[index] = TransactionInput(
                previousOutput: txin.previousOutput,
                signatureScript: unlockingScript,
                sequence: txin.sequence
            )
        }

        try verifyInputPubKeyHashes(transactionToSign, unsignedTx: unsignedTx)
        return transactionToSign
    }

    private func signingKey(from key: PrivateKey, matching pubkeyHash: Data) -> PrivateKey? {
        if standardHash160(key.publicKey().data) == pubkeyHash {
            return key
        }

        let alternateKey = PrivateKey(
            data: key.data,
            network: key.network,
            isPublicKeyCompressed: !key.isPublicKeyCompressed
        )
        if standardHash160(alternateKey.publicKey().data) == pubkeyHash {
            return alternateKey
        }

        return nil
    }

    private func verifyInputPubKeyHashes(_ signedTx: Transaction, unsignedTx: ElectrumXUnsignedTransaction) throws {
        for (index, utxo) in unsignedTx.utxos.enumerated() {
            let input = unsignedTx.inputs[index]
            let lockingPubKeyHash = Script.getPublicKeyHash(from: utxo.output.lockingScript).toHexString()
            let pushedPubKey = pushedPublicKey(from: signedTx.inputs[index].signatureScript)
            let pushedPubKeyHash = pushedPubKey.map { standardHash160($0).toHexString() } ?? "missing"
            let diagnostic = "input=\(index) txid=\(input.txID) vout=\(input.vout) expected=\(lockingPubKeyHash) actual=\(pushedPubKeyHash) script=\(input.scriptPubKey)"

            guard lockingPubKeyHash == pushedPubKeyHash else {
                throw ElectrumXWalletClientError.localScriptVerificationFailed(diagnostic)
            }
        }
    }

    private func pushedPublicKey(from signatureScript: Data) -> Data? {
        guard !signatureScript.isEmpty else {
            return nil
        }

        let signatureLength = Int(signatureScript[0])
        let publicKeyLengthIndex = 1 + signatureLength
        guard signatureScript.indices.contains(publicKeyLengthIndex) else {
            return nil
        }

        let publicKeyLength = Int(signatureScript[publicKeyLengthIndex])
        let publicKeyStart = publicKeyLengthIndex + 1
        let publicKeyEnd = publicKeyStart + publicKeyLength
        guard publicKeyEnd <= signatureScript.count else {
            return nil
        }

        return signatureScript[publicKeyStart..<publicKeyEnd]
    }

    private func convertCompactToDER(_ compactSignature: Data) throws -> Data {
        guard compactSignature.count == 64 else {
            throw NSError(
                domain: "SignatureError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Compact signature must be 64 bytes"]
            )
        }

        let r = derInteger(Data(compactSignature.prefix(32)))
        let s = derInteger(normalizedLowS(Data(compactSignature.suffix(32))))
        let sequence = r + s
        var der = Data([0x30])
        der.append(UInt8(sequence.count))
        der.append(sequence)
        return der
    }

    private func normalizedLowS(_ s: Data) -> Data {
        let halfOrder = hexData("7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0")
        let curveOrder = hexData("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141")
        guard s.count == 32, compare32(s, halfOrder) == .orderedDescending else {
            return s
        }

        return subtract32(curveOrder, s)
    }

    private func hexData(_ hex: String) -> Data {
        var result = Data()
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            let byte = UInt8(hex[index..<nextIndex], radix: 16) ?? 0
            result.append(byte)
            index = nextIndex
        }
        return result
    }

    private func compare32(_ lhs: Data, _ rhs: Data) -> ComparisonResult {
        for index in 0..<min(lhs.count, rhs.count) {
            if lhs[index] < rhs[index] {
                return .orderedAscending
            }
            if lhs[index] > rhs[index] {
                return .orderedDescending
            }
        }
        return lhs.count == rhs.count ? .orderedSame : (lhs.count < rhs.count ? .orderedAscending : .orderedDescending)
    }

    private func subtract32(_ lhs: Data, _ rhs: Data) -> Data {
        var result = [UInt8](repeating: 0, count: 32)
        var borrow = 0
        let lhsBytes = Array(lhs)
        let rhsBytes = Array(rhs)
        for offset in 0..<32 {
            let index = 31 - offset
            var value = Int(lhsBytes[index]) - Int(rhsBytes[index]) - borrow
            if value < 0 {
                value += 256
                borrow = 1
            } else {
                borrow = 0
            }
            result[index] = UInt8(value)
        }
        return Data(result)
    }

    private func derInteger(_ data: Data) -> Data {
        var value = Data(data)
        while value.count > 1 && value.first == 0 {
            value.removeFirst()
        }

        if let first = value.first, first & 0x80 != 0 {
            value = Data([0x00]) + value
        }

        var result = Data([0x02, UInt8(value.count)])
        result.append(value)
        return result
    }

    private func standardHash160(_ data: Data) -> Data {
        let sha256 = Crypto.sha256(data)
        return RIPEMD160.hash(sha256)
    }

    private func signDigest(_ digest: Data, privateKey: PrivateKey) throws -> Data {
        guard digest.count == 32 else {
            throw NSError(
                domain: "SignatureError",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Transaction digest must be 32 bytes"]
            )
        }

        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
            throw NSError(
                domain: "SignatureError",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Could not create secp256k1 signing context"]
            )
        }
        defer { secp256k1_context_destroy(context) }

        var signature = secp256k1_ecdsa_signature()
        let signResult = digest.withUnsafeBytes { digestPtr in
            privateKey.data.withUnsafeBytes { privateKeyPtr in
                secp256k1_ecdsa_sign(
                    context,
                    &signature,
                    digestPtr.bindMemory(to: UInt8.self).baseAddress!,
                    privateKeyPtr.bindMemory(to: UInt8.self).baseAddress!,
                    nil,
                    nil
                )
            }
        }

        guard signResult == 1 else {
            throw NSError(
                domain: "SignatureError",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Could not sign transaction digest"]
            )
        }

        var compactSignature = Data(repeating: 0, count: 64)
        compactSignature.withUnsafeMutableBytes { signaturePtr in
            secp256k1_ecdsa_signature_serialize_compact(
                context,
                signaturePtr.bindMemory(to: UInt8.self).baseAddress!,
                &signature
            )
        }

        return compactSignature
    }

    private func serializeTransaction(_ transaction: Transaction, timestamp: UInt32) -> Data {
        var data = Data()
        data += transaction.version.data
        data += timestamp.data
        data += transaction.txInCount.serialized()
        data += transaction.inputs.flatMap { $0.serialized() }
        data += transaction.txOutCount.serialized()
        data += transaction.outputs.flatMap { $0.serialized() }
        data += transaction.lockTime.data
        return data
    }

    private func signatureHash(
        _ transaction: Transaction,
        timestamp: UInt32,
        for utxoOutput: TransactionOutput,
        inputIndex: Int,
        hashType: SighashType.BTC
    ) -> Data {
        let helper = BTCSignatureHashHelper(hashType: hashType)
        guard inputIndex < transaction.inputs.count else {
            return helper.one
        }

        guard !(hashType.isSingle && inputIndex < transaction.outputs.count) else {
            return helper.one
        }

        let rawTransaction = Transaction(
            version: transaction.version,
            inputs: helper.createInputs(of: transaction, for: utxoOutput, inputIndex: inputIndex),
            outputs: helper.createOutputs(of: transaction, inputIndex: inputIndex),
            lockTime: transaction.lockTime
        )
        var data = serializeTransaction(rawTransaction, timestamp: timestamp)
        data += hashType.uint32.data

        return Crypto.sha256sha256(data)
    }

    private func acceptedTxProposal(_ txp: Vws.TxProposalResponse) -> Vws.TxProposalResponse {
        return txProposal(txp, status: "accepted")
    }

    private func broadcastedTxProposal(_ txp: Vws.TxProposalResponse) -> Vws.TxProposalResponse {
        return txProposal(txp, status: "broadcasted")
    }

    private func txProposal(_ txp: Vws.TxProposalResponse, status: String) -> Vws.TxProposalResponse {
        return Vws.TxProposalResponse(
            createdOn: txp.createdOn,
            coin: txp.coin,
            id: txp.id,
            network: txp.network,
            message: txp.message,
            inputs: txp.inputs,
            fee: txp.fee,
            status: status,
            creatorId: txp.creatorId,
            walletN: txp.walletN,
            walletM: txp.walletM,
            outputs: txp.outputs,
            amount: txp.amount,
            changeAddress: txp.changeAddress,
            walletId: txp.walletId,
            requiredSignatures: txp.requiredSignatures,
            version: txp.version,
            excludeUnconfirmedUtxos: txp.excludeUnconfirmedUtxos,
            addressType: txp.addressType,
            requiredRejections: txp.requiredRejections,
            outputOrder: txp.outputOrder,
            inputPaths: txp.inputPaths
        )
    }

    private func createAddress(_ plainAddress: String) throws -> Address {
        do {
            return try AddressFactory.create(plainAddress)
        } catch {
            guard let payload = Base58Check.decode(plainAddress), payload.count == 21 else {
                throw error
            }

            let versionByte = payload[0]
            let hashType: BitcoinAddress.HashType

            switch versionByte {
            case Network.mainnetXVG.pubkeyhash:
                hashType = .pubkeyHash
            case Network.mainnetXVG.scripthash:
                hashType = .scriptHash
            default:
                throw error
            }

            return try BitcoinAddress(
                data: payload.dropFirst(),
                hashType: hashType,
                network: .mainnetXVG
            )
        }
    }

    private func lockingScript(for address: Address) throws -> Script {
        guard let script = Script(address: address) else {
            throw ElectrumXWalletClientError.invalidDestinationAddress(address.description)
        }

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

    private func uint64Value(_ value: Any?) -> UInt64? {
        if let int = value as? Int {
            return UInt64(int)
        }

        if let int64 = value as? Int64 {
            return UInt64(int64)
        }

        if let uint64 = value as? UInt64 {
            return uint64
        }

        if let double = value as? Double {
            return UInt64(double)
        }

        if let string = value as? String {
            return UInt64(string)
        }

        return nil
    }

    private func uint32Value(_ value: Any?) -> UInt32? {
        guard let value = uint64Value(value) else {
            return nil
        }

        return UInt32(value)
    }
}

extension ElectrumXWalletClient.ElectrumXWalletClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unsupportedOperation:
            return "Sending from 18-word ElectrumX wallets is not implemented yet."
        case .addressDerivationFailed:
            return "Could not derive an ElectrumX wallet address."
        case .invalidDestinationAddress(let address):
            return "The entered address is not a valid Verge address: \(address)."
        case .insufficientFunds:
            return "Not enough confirmed XVG is available to cover this send and the network fee."
        case .noSpendableOutputs(let total):
            let amount = Double(total) / Constants.satoshiDivider
            return String(
                format: "ElectrumX found %.8f XVG on this wallet, but none of those UTXOs match a signing key. Those funds were likely received to an address generated by the old broken ElectrumX address hash. Send a new small test deposit to the current receive address before testing 18-word sends.",
                amount
            )
        case .missingSignedTransaction:
            return "The signed ElectrumX transaction could not be found."
        case .noSigningKeyFound(let path):
            return "No signing key was found for ElectrumX input \(path)."
        case .localScriptVerificationFailed(let message):
            return "The ElectrumX transaction failed local script verification: \(message)"
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
            return vwsClient
        }

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
