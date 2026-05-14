import Foundation
import Network
import Promises

enum ElectrumXClientError: Error {
    case noServersConfigured
    case invalidHTTPResponse
    case missingResult
}

struct ElectrumXConnectionStatus {
    let connected: Bool
    let server: ElectrumXServer?
}

final class ElectrumXClient {
    private let applicationRepository: ApplicationRepository
    private let urlSession: URLSession
    private let queue = DispatchQueue(label: "org.verge.wallets.electrumx")

    init(applicationRepository: ApplicationRepository, urlSession: URLSession = .shared) {
        self.applicationRepository = applicationRepository
        self.urlSession = urlSession
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
        request(servers: applicationRepository.orderedElectrumXServers, index: 0, method: method, params: params, completion: completion)
    }

    private func request(
        servers: [ElectrumXServer],
        index: Int,
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard servers.indices.contains(index) else {
            completion(.failure(ElectrumXClientError.noServersConfigured))
            return
        }

        requestSocket(server: servers[index], method: method, params: params) { result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self.request(servers: servers, index: index + 1, method: method, params: params, completion: completion)
            }
        }
    }

    func requestActiveServer(
        method: String,
        params: [Any],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        requestSocket(server: applicationRepository.activeElectrumXServer, method: method, params: params, completion: completion)
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

        requestSocket(server: servers[index], method: "server.version", params: ["VergeiOS", "1.4"]) { result in
            switch result {
            case .success:
                completion(ElectrumXConnectionStatus(connected: true, server: servers[index]))
            case .failure:
                self.checkConnection(servers: servers, index: index + 1, completion: completion)
            }
        }
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

                while let frameRange = self.firstJSONFrameRange(in: responseBuffer) {
                    let frame = responseBuffer.subdata(in: frameRange)
                    responseBuffer.removeSubrange(responseBuffer.startIndex..<frameRange.upperBound)

                    do {
                        let json = try JSONSerialization.jsonObject(with: frame) as? [String: Any]
                        if json?["id"] as? String != requestId {
                            continue
                        }

                        if json?["result"] == nil {
                            if let error = json?["error"] {
                                print("ElectrumX \(server.host) \(method) error: \(error)")
                            }
                            print("ElectrumX \(method) missing result: \(json ?? [:])")
                            finish(.failure(ElectrumXClientError.missingResult))
                            return
                        }

                        finish(.success(json ?? [:]))
                    } catch {
                        print("ElectrumX \(method) decode error: \(error.localizedDescription)")
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

    private func request(
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

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if json?["result"] == nil {
                    completion(.failure(ElectrumXClientError.missingResult))
                    return
                }

                completion(.success(json ?? [:]))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
