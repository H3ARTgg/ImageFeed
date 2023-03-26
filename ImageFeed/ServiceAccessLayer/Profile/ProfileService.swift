import Foundation
private enum Errors: String, Error {
    case failedToParseData = "Failed to parse data"
}

public protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {
    // MARK: Singleton and Properties
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private var lastCode: String?
    private(set) var profile: Profile?
    
    // MARK: - fetchProfile
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        }
        
        var request = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: profileResult.name,
                    bio: profileResult.bio
                )
                self.profile = profile
                completion(.success(profileResult))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
