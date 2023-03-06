import Foundation
import SwiftKeychainWrapper

private enum Errors: String, Error {
    case failedToParseData = "Failed to parse data"
    case failedToSaveToken = "Failed to save token"
}

final class OAuth2Service: OAuth2ServiceProtocol {
    // MARK: - Properties
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - fetchOAuthToken
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request =  authTokenRequest(code: code)
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
                self.lastCode = nil
            case .success(let responseBody):
                let authToken = responseBody.accessToken
                let isSuccess = KeychainWrapper.standard.set(authToken, forKey: "Auth token")
                guard isSuccess else {
                    completion(.failure(Errors.failedToSaveToken))
                    return
                }
                completion(.success(authToken))
                self.task = nil
            }
        }
        self.task = task
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
