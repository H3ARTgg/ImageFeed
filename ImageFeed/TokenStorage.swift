import SwiftKeychainWrapper

struct TokenStorage {
    static let tokenKey: String = "Auth token"
    static let token: String? = KeychainWrapper.standard.string(forKey: TokenStorage.tokenKey)
}
