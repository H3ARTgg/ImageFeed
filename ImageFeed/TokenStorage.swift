import SwiftKeychainWrapper

final class TokenStorage {
    static let shared = TokenStorage()
    let tokenKey: String = "Auth token"
    private (set) var token: String? {
        get {
            let token = KeychainWrapper.standard.string(forKey: tokenKey)
            return token
        }
        set {
            _ = KeychainWrapper.standard.removeObject(forKey: tokenKey)
        }
    }
    
    func removeToken() {
        token = ""
    }
}
