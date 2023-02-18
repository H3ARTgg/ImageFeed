import Foundation

private enum Errors: String, Error {
    case statusCodeError = "Error status code"
    case failedToParseData = "Failed to parse data"
}

final class OAuth2Service: OAuth2ServiceProtocol {
    private (set) var authToken: String? {
          get {
              return OAuth2TokenStorage().token
          }
          set {
              OAuth2TokenStorage().token = newValue
    } }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request =  authTokenRequest(code: code)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                DispatchQueue.main.async {
                    completion(.failure(Errors.statusCodeError))
                }
            }
            
            guard let data = data else { return }
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
        task.resume()
    }
}

extension OAuth2Service {
    func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }
}
