import Foundation
import Network
import Promises

enum ElectrumXClientError: Error {
    case noServersConfigured
    case invalidHTTPResponse
    case missingResult
    case serverError(String)
}

struct ElectrumXConnectionStatus {
    let connected: Bool
    let server: ElectrumXServer?
}

final class ElectrumXClient {
    private let applicationRepository: ApplicationRepository
    private let urlSession: URLSession
    private let httpSession: HttpSessionProtocol?
    private let hiddenClient: HiddenClientProtocol?
    private let queue = DispatchQueue(label: "org.verge.wallets.electrumx")
    private var persistentSocket: PersistentSocket?

    init(
        applicationRepository: ApplicationRepository,
        urlSession: URLSession = .shared,
        httpSession: HttpSessionProtocol? = nil,
        hiddenClient: HiddenClientProtocol? = nil
    ) {
        self.applicationRepository = applicationRepository
        self.urlSession = urlSession
        self.httpSession = httpSession
        self.hiddenClient = hiddenClient
    }

    func serverVersion() -> Promise<String> {
        return request(method: "server.version", params: ["VergeiOS", "1.4"]).then { json in
            if let version = json["result"] as? String {
                return version
            }

            if let versions = json["result"] as? [String] {
                return versions.joined(separator: " ")
            }

            throw ElectrumXClientError.missingResult
        }
    }

    func checkConnection(completion: @escaping (ElectrumXConnectionStatus) -> Void) {
        let servers = applicationRepository.orderedElectrumXServers
        guard !servers.isEmpty else {
            completion(ElectrumXConnectionStatus(connected: false, server: nil))
            return
        }

        checkConnection(servers: servers, index: 0, completion: completion)
    }

    func request(method: String, params: [Any]) -> Promise<[String: Any]> {
        return Promise<[String: Any]> { fulfill, reject in
            self.request(method: method, params: params) { result in
                switch result {
                case .success(let json):
                    fulfill(json)
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }

    func request(
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        request(
            servers: applicationRepository.orderedElectrumXServers,
            index: 0,
            method: method,
            params: params,
            lastError: nil,
            completion: completion
        )
    }

    private func request(
        servers: [ElectrumXServer],
        index: Int,
        method: String,
        params: [Any],
        lastError: Error?,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard servers.indices.contains(index) else {
            completion(.failure(lastError ?? ElectrumXClientError.noServersConfigured))
            return
        }

        requestTransport(server: servers[index], method: method, params: params) { result in
            switch result {
            case .success:
                completion(result)
            case .failure(let error):
                self.request(
                    servers: servers,
                    index: index + 1,
                    method: method,
                    params: params,
                    lastError: error,
                    completion: completion
                )
            }
        }
    }

    func requestActiveServer(
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        requestTransport(server: applicationRepository.activeElectrumXServer, method: method, params: params, completion: completion)
    }

    private func checkConnection(
        servers: [ElectrumXServer],
        index: Int,
        completion: @escaping (ElectrumXConnectionStatus) -> Void
    ) {
        guard servers.indices.contains(index) else {
            completion(ElectrumXConnectionStatus(connected: false, server: nil))
            return
        }

        requestTransport(server: servers[index], method: "server.version", params: ["VergeiOS", "1.4"]) { result in
            switch result {
            case .success:
                completion(ElectrumXConnectionStatus(connected: true, server: servers[index]))
            case .failure:
                self.checkConnection(servers: servers, index: index + 1, completion: completion)
            }
        }
    }

    private func requestTransport(
        server: ElectrumXServer,
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        if applicationRepository.useTor {
            requestWebSocket(server: server, method: method, params: params, completion: completion)
        } else {
            requestPersistentSocket(server: server, method: method, params: params) { result in
                switch result {
                case .success:
                    completion(result)
                case .failure:
                    self.requestSocket(server: server, method: method, params: params, completion: completion)
                }
            }
        }
    }

    private func requestPersistentSocket(
        server: ElectrumXServer,
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        queue.async {
            if self.persistentSocket?.server != server {
                self.persistentSocket?.disconnect()
                self.persistentSocket = PersistentSocket(
                    server: server,
                    queue: self.queue,
                    responseError: { [weak self] json in
                        self?.responseError(from: json)
                    }
                )
            }

            self.persistentSocket?.request(method: method, params: params) { result in
                if case .failure = result {
                    self.queue.async {
                        if self.persistentSocket?.server == server {
                            self.persistentSocket?.disconnect()
                            self.persistentSocket = nil
                        }
                    }
                }

                completion(result)
            }
        }
    }

    private func requestWebSocket(
        server: ElectrumXServer,
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard let hiddenClient = hiddenClient,
              let url = server.webSocketURL else {
            completion(.failure(ElectrumXClientError.invalidHTTPResponse))
            return
        }

        hiddenClient.getURLSession().then { session in
            self.requestWebSocket(
                session: session,
                url: url,
                method: method,
                params: params,
                completion: completion
            )
        }.catch { error in
            completion(.failure(error))
        }
    }

    private func requestWebSocket(
        session: URLSession,
        url: URL,
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        let task = session.webSocketTask(with: url)
        let requestId = UUID().uuidString
        var didComplete = false

        func finish(_ result: Result<[String: Any], Error>) {
            self.queue.async {
                guard !didComplete else {
                    return
                }

                didComplete = true
                task.cancel(with: .normalClosure, reason: nil)
                completion(result)
            }
        }

        func send(method: String, params: [Any], id: String) {
            do {
                let payload = try JSONSerialization.data(withJSONObject: [
                    "id": id,
                    "method": method,
                    "params": params
                ])
                let message = URLSessionWebSocketTask.Message.data(payload)
                task.send(message) { error in
                    if let error = error {
                        finish(.failure(error))
                    }
                }
            } catch {
                finish(.failure(error))
            }
        }

        func receive() {
            task.receive { result in
                switch result {
                case .success(let message):
                    let data: Data?
                    switch message {
                    case .data(let messageData):
                        data = messageData
                    case .string(let messageString):
                        data = messageString.data(using: .utf8)
                    @unknown default:
                        data = nil
                    }

                    guard let data = data,
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        receive()
                        return
                    }

                    guard json["id"] as? String == requestId else {
                        receive()
                        return
                    }

                    if let error = self.responseError(from: json) {
                        finish(.failure(error))
                        return
                    }

                    if json["result"] == nil {
                        finish(.failure(ElectrumXClientError.missingResult))
                        return
                    }

                    finish(.success(json))
                case .failure(let error):
                    finish(.failure(error))
                }
            }
        }

        queue.asyncAfter(deadline: .now() + 8) {
            finish(.failure(ElectrumXClientError.invalidHTTPResponse))
        }

        task.resume()
        receive()

        if method != "server.version" {
            send(method: "server.version", params: ["VergeiOS", "1.4"], id: "server.version.\(requestId)")
        }
        send(method: method, params: params, id: requestId)
    }

    private func requestSocket(
        server: ElectrumXServer,
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard let port = NWEndpoint.Port(rawValue: UInt16(server.port)) else {
            completion(.failure(ElectrumXClientError.noServersConfigured))
            return
        }

        let parameters = server.useTLS ? NWParameters.tls : NWParameters.tcp
        let connection = NWConnection(host: NWEndpoint.Host(server.host), port: port, using: parameters)
        var didComplete = false
        var responseBuffer = Data()
        let requestId = UUID().uuidString

        func finish(_ result: Result<[String: Any], Error>) {
            self.queue.async {
                guard !didComplete else {
                    return
                }

                didComplete = true
                connection.cancel()
                completion(result)
            }
        }

        func readResponse() {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
                if let error = error {
                    finish(.failure(error))
                    return
                }

                if let data = data, !data.isEmpty {
                    responseBuffer.append(data)
                }

                while let frameRange = Self.firstJSONFrameRange(in: responseBuffer) {
                    let frame = responseBuffer.subdata(in: frameRange)
                    responseBuffer.removeSubrange(responseBuffer.startIndex..<frameRange.upperBound)

                    do {
                        let json = try JSONSerialization.jsonObject(with: frame) as? [String: Any]
                        if json?["id"] as? String != requestId {
                            continue
                        }

                        if let error = self.responseError(from: json ?? [:]) {
                            finish(.failure(error))
                            return
                        }

                        if json?["result"] == nil {
                            finish(.failure(ElectrumXClientError.missingResult))
                            return
                        }

                        finish(.success(json ?? [:]))
                    } catch {
                        finish(.failure(error))
                    }

                    return
                }

                if isComplete {
                    finish(.failure(ElectrumXClientError.invalidHTTPResponse))
                    return
                }

                readResponse()
            }
        }

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                do {
                    let payload = try JSONSerialization.data(withJSONObject: [
                        "id": requestId,
                        "method": method,
                        "params": params
                    ])

                    var framedPayload = Data()
                    if method != "server.version" {
                        let versionPayload = try JSONSerialization.data(withJSONObject: [
                            "id": "server.version.\(requestId)",
                            "method": "server.version",
                            "params": ["VergeiOS", "1.4"]
                        ])
                        framedPayload.append(versionPayload)
                        framedPayload.append(0x0a)
                    }

                    framedPayload.append(payload)
                    framedPayload.append(0x0a)

                    connection.send(content: framedPayload, completion: .contentProcessed { error in
                        if let error = error {
                            finish(.failure(error))
                        }
                    })

                    readResponse()
                } catch {
                    finish(.failure(error))
                }
            case .failed(let error):
                finish(.failure(error))
            case .cancelled:
                break
            default:
                break
            }
        }

        queue.asyncAfter(deadline: .now() + 5) {
            finish(.failure(ElectrumXClientError.invalidHTTPResponse))
        }

        connection.start(queue: queue)
    }

    private static func firstJSONFrameRange(in data: Data) -> Range<Data.Index>? {
        var startIndex: Data.Index?
        var depth = 0
        var inString = false
        var escaped = false
        var index = data.startIndex

        while index < data.endIndex {
            let byte = data[index]

            if startIndex == nil {
                if byte == 0x7b {
                    startIndex = index
                    depth = 1
                }
                index = data.index(after: index)
                continue
            }

            if escaped {
                escaped = false
            } else if byte == 0x5c {
                escaped = inString
            } else if byte == 0x22 {
                inString.toggle()
            } else if !inString && byte == 0x7b {
                depth += 1
            } else if !inString && byte == 0x7d {
                depth -= 1
                if depth == 0, let startIndex = startIndex {
                    return startIndex..<data.index(after: index)
                }
            }

            index = data.index(after: index)
        }

        return nil
    }

    private func requestHTTP(
        server: ElectrumXServer,
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard let url = server.url else {
            completion(.failure(ElectrumXClientError.noServersConfigured))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "id": UUID().uuidString,
                "method": method,
                "params": params
            ])
        } catch {
            completion(.failure(error))
            return
        }

        if let httpSession = httpSession {
            httpSession.dataTask(with: request).then { response in
                guard let httpResponse = response.urlResponse as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    completion(.failure(ElectrumXClientError.invalidHTTPResponse))
                    return
                }

                self.decodeResponseData(response.data, completion: completion)
            }.catch { error in
                completion(.failure(error))
            }

            return
        }

        guard !applicationRepository.useTor else {
            completion(.failure(ElectrumXClientError.invalidHTTPResponse))
            return
        }

        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode,
                  let data = data else {
                completion(.failure(ElectrumXClientError.invalidHTTPResponse))
                return
            }

            self.decodeResponseData(data, completion: completion)
        }.resume()
    }

    private func responseError(from json: [String: Any]) -> Error? {
        guard let error = json["error"] as? [String: Any] else {
            return nil
        }

        if let message = error["message"] as? String, !message.isEmpty {
            return ElectrumXClientError.serverError(message)
        }

        if let code = error["code"] {
            return ElectrumXClientError.serverError("ElectrumX error \(code)")
        }

        return ElectrumXClientError.serverError("Unknown ElectrumX server error")
    }

    private func decodeResponseData(
        _ data: Data,
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let error = responseError(from: json ?? [:]) {
                completion(.failure(error))
                return
            }

            if json?["result"] == nil {
                completion(.failure(ElectrumXClientError.missingResult))
                return
            }

            completion(.success(json ?? [:]))
        } catch {
            completion(.failure(error))
        }
    }
}

private final class PersistentSocket {
    let server: ElectrumXServer

    private let queue: DispatchQueue
    private let responseError: ([String: Any]) -> Error?
    private var connection: NWConnection?
    private var responseBuffer = Data()
    private var isReady = false
    private var isConnecting = false
    private var connectCompletions = [(Result<Void, Error>) -> Void]()
    private var pending = [String: (Result<[String: Any], Error>) -> Void]()

    init(
        server: ElectrumXServer,
        queue: DispatchQueue,
        responseError: @escaping ([String: Any]) -> Error?
    ) {
        self.server = server
        self.queue = queue
        self.responseError = responseError
    }

    func request(
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        queue.async {
            self.connect { result in
                switch result {
                case .success:
                    self.send(method: method, params: params, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func disconnect() {
        queue.async {
            self.disconnectOnQueue(error: ElectrumXClientError.invalidHTTPResponse)
        }
    }

    private func connect(completion: @escaping (Result<Void, Error>) -> Void) {
        if isReady {
            completion(.success(()))
            return
        }

        connectCompletions.append(completion)
        guard !isConnecting else {
            return
        }

        guard let port = NWEndpoint.Port(rawValue: UInt16(server.port)) else {
            finishConnect(.failure(ElectrumXClientError.noServersConfigured))
            return
        }

        isConnecting = true
        let parameters = server.useTLS ? NWParameters.tls : NWParameters.tcp
        let connection = NWConnection(host: NWEndpoint.Host(server.host), port: port, using: parameters)
        self.connection = connection

        connection.stateUpdateHandler = { [weak self] state in
            guard let self = self else {
                return
            }

            self.queue.async {
                switch state {
                case .ready:
                    self.isReady = true
                    self.isConnecting = false
                    self.readLoop()
                    self.finishConnect(.success(()))
                case .failed(let error):
                    self.disconnectOnQueue(error: error)
                case .cancelled:
                    if self.isReady || self.isConnecting {
                        self.disconnectOnQueue(error: ElectrumXClientError.invalidHTTPResponse)
                    }
                default:
                    break
                }
            }
        }

        connection.start(queue: queue)

        queue.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self, !self.isReady else {
                return
            }

            self.disconnectOnQueue(error: ElectrumXClientError.invalidHTTPResponse)
        }
    }

    private func send(
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard let connection = connection, isReady else {
            completion(.failure(ElectrumXClientError.invalidHTTPResponse))
            return
        }

        let requestId = UUID().uuidString
        pending[requestId] = completion

        do {
            var payload = Data()
            if method != "server.version" {
                let versionPayload = try JSONSerialization.data(withJSONObject: [
                    "id": "server.version.\(requestId)",
                    "method": "server.version",
                    "params": ["VergeiOS", "1.4"]
                ])
                payload.append(versionPayload)
                payload.append(0x0a)
            }

            let requestPayload = try JSONSerialization.data(withJSONObject: [
                "id": requestId,
                "method": method,
                "params": params
            ])
            payload.append(requestPayload)
            payload.append(0x0a)

            connection.send(content: payload, completion: .contentProcessed { [weak self] error in
                guard let self = self, let error = error else {
                    return
                }

                self.queue.async {
                    if let completion = self.pending.removeValue(forKey: requestId) {
                        completion(.failure(error))
                    }
                    self.disconnectOnQueue(error: error)
                }
            })

            queue.asyncAfter(deadline: .now() + 8) { [weak self] in
                guard let self = self,
                      let completion = self.pending.removeValue(forKey: requestId) else {
                    return
                }

                completion(.failure(ElectrumXClientError.invalidHTTPResponse))
            }
        } catch {
            pending.removeValue(forKey: requestId)
            completion(.failure(error))
        }
    }

    private func readLoop() {
        guard let connection = connection, isReady else {
            return
        }

        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else {
                return
            }

            self.queue.async {
                if let error = error {
                    self.disconnectOnQueue(error: error)
                    return
                }

                if let data = data, !data.isEmpty {
                    self.responseBuffer.append(data)
                    self.consumeResponseBuffer()
                }

                if isComplete {
                    self.disconnectOnQueue(error: ElectrumXClientError.invalidHTTPResponse)
                    return
                }

                self.readLoop()
            }
        }
    }

    private func consumeResponseBuffer() {
        while let frameRange = firstJSONFrameRange(in: responseBuffer) {
            let frame = responseBuffer.subdata(in: frameRange)
            responseBuffer.removeSubrange(responseBuffer.startIndex..<frameRange.upperBound)

            guard let json = try? JSONSerialization.jsonObject(with: frame) as? [String: Any],
                  let id = json["id"] as? String,
                  let completion = pending.removeValue(forKey: id) else {
                continue
            }

            if let error = responseError(json) {
                completion(.failure(error))
                continue
            }

            if json["result"] == nil {
                completion(.failure(ElectrumXClientError.missingResult))
                continue
            }

            completion(.success(json))
        }
    }

    private func finishConnect(_ result: Result<Void, Error>) {
        let completions = connectCompletions
        connectCompletions.removeAll()
        completions.forEach { $0(result) }
    }

    private func disconnectOnQueue(error: Error) {
        let wasActive = isReady || isConnecting || connection != nil
        isReady = false
        isConnecting = false
        responseBuffer.removeAll()
        connection?.cancel()
        connection = nil

        if wasActive {
            finishConnect(.failure(error))
        }

        let completions = pending.values
        pending.removeAll()
        completions.forEach { $0(.failure(error)) }
    }

    private func firstJSONFrameRange(in data: Data) -> Range<Data.Index>? {
        var startIndex: Data.Index?
        var depth = 0
        var inString = false
        var escaped = false
        var index = data.startIndex

        while index < data.endIndex {
            let byte = data[index]

            if startIndex == nil {
                if byte == 0x7b {
                    startIndex = index
                    depth = 1
                }
                index = data.index(after: index)
                continue
            }

            if escaped {
                escaped = false
            } else if byte == 0x5c {
                escaped = inString
            } else if byte == 0x22 {
                inString.toggle()
            } else if !inString && byte == 0x7b {
                depth += 1
            } else if !inString && byte == 0x7d {
                depth -= 1
                if depth == 0, let startIndex = startIndex {
                    return startIndex..<data.index(after: index)
                }
            }

            index = data.index(after: index)
        }

        return nil
    }
}

extension ElectrumXClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noServersConfigured:
            return "No ElectrumX servers are configured."
        case .invalidHTTPResponse:
            return "The ElectrumX server returned an invalid response."
        case .missingResult:
            return "The ElectrumX server response was missing a result."
        case .serverError(let message):
            return message
        }
    }
}
