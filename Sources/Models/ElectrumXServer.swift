import Foundation

struct ElectrumXServer: Codable, Equatable {
    var host: String
    var port: Int
    var useTLS: Bool

    var displayName: String {
        return "\(scheme)://\(host):\(port)"
    }

    var scheme: String {
        return useTLS ? "ssl" : "tcp"
    }

    var url: URL? {
        return URL(string: "\(useTLS ? "https" : "http")://\(host):\(port)")
    }
}
