import Foundation

final class OAuth2TokenStorage {
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let tokenKey: String = "tokenKey"
    
    var token: String? {
        get {
            guard let result = userDefaults.string(forKey: tokenKey) else {
                return nil
            }
            return result
        }
        set {
            userDefaults.setValue(newValue, forKey: tokenKey)
        }
    }
}
