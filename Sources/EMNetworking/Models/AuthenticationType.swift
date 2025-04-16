import Foundation

public enum AuthenticationType {
    case bearer
    case basic(username: String, password: String)
    case custom(prefix: String)
    case none

    var headerPrefix: String {
        switch self {
            case .bearer: "Bearer"
            case .basic: "Basic"
            case let .custom(prefix): prefix
            case .none: ""
        }
    }

    func format(token: String) -> String {
        switch self {
            case .bearer, .custom:
                return "\(headerPrefix) \(token)"
            case let .basic(username, password):
                let credentials = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
                return "\(headerPrefix) \(credentials)"
            case .none:
                return token
        }
    }
}
