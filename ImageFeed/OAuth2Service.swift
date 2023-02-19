import Foundation

private enum Errors: String, Error {
    case failedToParseData = "Failed to parse data"
}

final class OAuth2Service: OAuth2ServiceProtocol {
    // MARK: - Properties
    private let tokenStorage = OAuth2TokenStorage()
    private (set) var authToken: String? {
          get {
              return tokenStorage.token
          }
          set {
              tokenStorage.token = newValue
    } }
    
    // MARK: - fetchOAuthToken
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request =  authTokenRequest(code: code)
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let authToken = responseBody.accessToken
                    self.authToken = authToken
                    DispatchQueue.main.async {
                        completion(.success(authToken))
                    }

                } catch {
                    print(Errors.failedToParseData.rawValue)
                }
            }
        }
        task.resume()
    }
}

// MARK: - Extenstion
extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(accessKey)"
            + "&&client_secret=\(secretKey)"
            + "&&redirect_uri=\(redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }
}
