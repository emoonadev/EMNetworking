## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/emoonadev/EMNetworking.git", from: "1.4.0")
]
```

## 🚀 Quick Start

### 1. Define Your API Routes
```swift
import EMNetworking

enum MyAPI {
    #BaseURL("https://api.example.com") {
        
        @Controller("users/")
        enum Users {
            @HTTP(.get, path: "profile", .parameter("userID"))
            case profile(userID: String)
            
            @HTTP(.get, path: "profile", "me")
            case myProfile
            
            @HTTP(.post, path: "update")
            case updateProfile(UpdateProfileRequest)
        }
        
        @Controller("auth/")
        enum Auth {
            @HTTP(.post, path: "login", isAuthRequired: false)
            case login(LoginRequest)
        }
    }
    
    #BaseURL("https://api.example.com", 
             dev: "https://dev-api.example.com", 
             staging: "https://staging-api.example.com",
             contentType: .formURLEncoded()) {
        
        @Controller("forms/")
        enum Forms {
            @HTTP(.post, path: "submit")
            case submitForm(FormData)
        }
    }
}
```
### 2. Configure Network Manager
```swift
// Token Manager
class MyTokenManager: TokenManaging {
    var token: String { 
        KeychainStorage.shared.getToken() ?? ""
    }
    
    var isTokenValid: Bool {
        guard let expiryDate = KeychainStorage.shared.getTokenExpiry() else { return false }
        return Date() < expiryDate
    }
    
    func refreshToken() async throws -> String {
        let refreshToken = KeychainStorage.shared.getRefreshToken() ?? ""
        let response: RefreshTokenResponse = try await networkManager.perform(
            route: MyAPI.Auth.refreshToken(RefreshTokenRequest(refreshToken: refreshToken))
        )
        KeychainStorage.shared.saveToken(response.accessToken)
        return response.accessToken
    }
}

// Configure authentication
let tokenManager = MyTokenManager()
let accessToken = EMConfigurator.AccessToken(
    authenticationType: .bearer,
    refreshTokenManager: tokenManager
)

// Configure headers
let headers = EMConfigurator.Header {
    var headers = [String: String]()
    headers["User-Agent"] = "MyApp/1.0.0 (iOS)"
    headers["Accept-Language"] = "en"
    headers["X-API-Key"] = "your-api-key"
    headers["X-Client-Version"] = Bundle.main.version
    return headers
}

// Configure query parameters
let queryParams = EMConfigurator.URLQueryParameter {
    [
        URLQueryItem(name: "version", value: "1.0"),
        URLQueryItem(name: "platform", value: "ios"),
        URLQueryItem(name: "device_id", value: UIDevice.current.identifierForVendor?.uuidString ?? "")
    ]
}

// Environment configuration
let environment = EMConfigurator.Environment {
    #if DEBUG
    return .dev
    #elseif STAGING
    return .staging
    #else
    return .prod
    #endif
}

// Certificate Pinning (Optional)
let certificatePinning = DefaultCertificatePinning.publicKeyPinning(
    withCertificateNames: ["api_certificate", "backup_certificate"]
)

// Logging
let logHandler = LogHandler(
    inputHandler: { log in
        print("📥 \(log.statusCode) \(log.httpMethod) - \(log.responseTimeMillis)ms")
        print("URL: \(log.requestURL?.absoluteString ?? "")")
    },
    outputHandler: { log in
        print("📤 \(log.httpMethod) \(log.requestURL?.absoluteString ?? "")")
    }
)

// Create network manager
let networkManager = EMNetwork(
    configurator: EMConfigurator(
        urlSessionConfiguration: {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.httpShouldSetCookies = false
            return config
        }(),
        accessTokenConfigurator: accessToken,
        headerConfigurator: headers,
        urlQueryParametersConfigurator: queryParams,
        environmentConfigurator: environment,
        certificatePinningConfigurator: certificatePinning
    ),
    serverResponseParser: CustomResponseParser(),
    logHandler: logHandler
)
```
### 3. Make Network Requests
```swift
// Simple request with response
let userProfile: UserProfile = try await networkManager.perform(
    route: MyAPI.Users.profile(userID: "123")
)

// Request without return data
try await networkManager.perform(
    route: MyAPI.Users.updateProfile(updateData)
)

// Handle errors
do {
    let searchResults: SearchResults = try await networkManager.perform(
        route: MyAPI.Users.searchUsers(dto: SearchUsersRequest(query: "john"))
    )
} catch {
    print("Request failed: \(error)")
}
```
## 📖 Advanced Features

### Macro-Based Route Definition

#### @BaseURL - Multi-Environment Support
```swift
#BaseURL("https://api.example.com",
         dev: "https://dev-api.example.com",
         staging: "https://staging-api.example.com",
         test: "https://test-api.example.com",
         contentType: .json) {
    // Routes defined here
}
```

#### @Controller - Group Related Endpoints

```swift
@Controller("api/v2/users/")
enum Users {
    // User endpoints with /api/v2/users/ prefix
}
```

#### @HTTP - Define Individual Endpoints

```swift
// GET with path parameters
@HTTP(.get, path: "profile", .parameter("id"))
case userById(id: String)

// POST with request body
@HTTP(.post, path: "create")
case createUser(CreateUserRequest)

// No authentication required
@HTTP(.get, path: "public-data", isAuthRequired: false)
case publicData

// Multiple path segments
@HTTP(.get, path: "users", .parameter("id"), "posts")
case userPosts(id: String)
```
### Authentication Types
```swift
// Bearer Token (most common)
.bearer  // "Bearer your-token"

// Basic Authentication
.basic(username: "user", password: "pass")  // "Basic base64(user:pass)"

// Custom Header Format
.custom(prefix: "Token")  // "Token your-token"

// No Authentication Processing
.none  // Raw token value
```

### Content Types & Form Encoding

```swift
// JSON (default)
contentType: .json

// Form URL Encoded with custom options
contentType: .formURLEncoded(
    alphabetizeKeyValuePairs: true,
    arrayEncoding: .brackets,  // array[0]=value1&array[1]=value2
    boolEncoding: .numeric,    // true=1, false=0
    spaceEncoding: .percentEscaped,
    allowedCharacters: .urlQueryAllowed
)

// Other supported types
.xml, .plainText, .html, .css, .javascript
.png, .jpeg, .gif, .svg, .webp
.pdf, .zip, .gzip, .octetStream
```

### Certificate Pinning

#### Public Key Pinning (Recommended)
```swift
// Flexible - survives certificate renewals
let publicKeyPinning = DefaultCertificatePinning.publicKeyPinning(
    withCertificateNames: ["server_cert"]
)
```

#### Certificate Pinning

```swift
// Strict - requires app update on cert renewal
let certificatePinning = DefaultCertificatePinning.certificatePinning(
    withCertificateNames: ["server_cert"]
)
```

#### Custom Pinning Strategy
```swift
let customPinning = DefaultCertificatePinning(
    strategy: .publicKey([publicKeyData]),
    allowSelfSignedCertificates: false
)
```

### Data Models with @EMCodable

```swift
@EMCodable
struct LoginRequest {
    let email: String
    let password: String
    let deviceId: String
    let rememberMe: Bool
}

@EMCodable(codingKeyStrategy: .snakeCase)
struct UserProfile {
    let userId: String          // Maps to "user_id"
    let fullName: String        // Maps to "full_name"
    let emailAddress: String    // Maps to "email_address"
    let createdAt: Date         // Maps to "created_at"
}

@EMCodable
struct CustomKeyExample {
    let id: String
    
    @EMCodingKey("custom_field_name")
    let specialField: String
}
```

### Custom Response Parser

```swift
struct MyResponseParser: ServerResponseParser {
    func parse<T: Codable>(data: Data) throws -> ServerResponse<T> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Handle your API response format
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let dict = jsonObject as? [String: Any] else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Invalid response format")
            )
        }
        
        let success = dict["success"] as? Bool ?? false
        let message = dict["message"] as? String
        
        var responseData: T?
        if let dataField = dict["data"] {
            let dataJSON = try JSONSerialization.data(withJSONObject: dataField)
            responseData = try decoder.decode(T.self, from: dataJSON)
        }
        
        if !success {
            throw NSError(domain: "APIError", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: message ?? "Unknown error"])
        }
        
        return ServerResponse(message: message, data: responseData)
    }
}
```

### Advanced Configuration

#### URL Session Configuration
```swift
let configurator = EMConfigurator(
    urlSessionConfiguration: {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.httpMaximumConnectionsPerHost = 6
        config.httpShouldSetCookies = false
        config.httpCookieStorage = nil
        return config
    }(),
    // ... other configurations
)
```

#### Header Filtering with IgnoreValue

```swift
let headers = EMConfigurator.Header {
    var headers = [String: String]()
    headers["X-User-ID"] = currentUser?.id ?? IgnoreValue.ignore
    return headers
}
```

## 🛡️ Security Features

### Certificate Pinning Benefits
- **Prevents MITM attacks** - Blocks interception tools like Proxyman, Charles Proxy
- **Public Key Pinning** - Flexible, survives certificate renewals
- **Certificate Pinning** - Maximum security, requires app updates on cert renewal
- **Multiple Certificate Support** - Pin multiple certificates for backup/rotation

### Authentication Security
- **Automatic token refresh** - Seamless user experience with retry logic
- **Multiple auth types** - Bearer, Basic, Custom header formats
- **Secure token storage** - Integrate with Keychain or other secure storage
- **Thread-safe operations** - Concurrent request handling with proper token management

## 🐛 Error Handling

```swift
do {
    let result: APIResponse = try await networkManager.perform(
        route: MyAPI.Users.profile(userID: "123")
    )
} catch let urlError as URLError {
    switch urlError.code {
    case .notConnectedToInternet:
        print("No internet connection")
    case .timedOut:
        print("Request timed out")
    case .serverCertificateUntrusted:
        print("Certificate pinning failed")
    default:
        print("Network error: \(urlError.localizedDescription)")
    }
} catch let decodingError as DecodingError {
    print("JSON parsing error: \(decodingError)")
} catch let nsError as NSError {
    if nsError.domain == "com.emNetwork.error" {
        switch nsError.code {
        case -338:
            print("Token refresh in progress")
        case -232:
            print("Server error")
        default:
            print("Network library error: \(nsError.localizedDescription)")
        }
    }
} catch {
    print("Unknown error: \(error)")
}
```

## 📚 Complete Feature List

### Core Features
- ✅ Macro-based API route definitions
- ✅ Multi-environment URL configuration
- ✅ Automatic authentication header injection
- ✅ Token refresh with retry logic
- ✅ Certificate and public key pinning
- ✅ Comprehensive request/response logging
- ✅ Custom response parsing
- ✅ Multiple content type support
- ✅ URL query parameter encoding/decoding
- ✅ Header value filtering
- ✅ Async/await support
- ✅ Thread-safe operations
- ✅ URLSession configuration customization

### Content Types Supported
- JSON, XML, HTML, CSS, JavaScript, Plain Text
- Form URL Encoded (with advanced options)
- Form Data (multipart)
- Images: PNG, JPEG, GIF, SVG, WebP
- Documents: PDF, ZIP, GZIP
- Binary: Octet Stream

### Authentication Types
- Bearer Token, Basic Auth, Custom Headers, No Auth

### Certificate Pinning Options
- Public Key Pinning, Certificate Pinning, CA Pinning

### Logging Features
- Request/Response logging, Custom log handlers, Performance metrics

### Advanced Features
- Custom coding key strategies, Value filtering, Multi-certificate support
- Environment-specific configurations, Query parameter customization

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For questions or issues, please open an issue on GitHub.

---

**EMNetworking** - Modern Swift networking made simple and secure. 🚀
