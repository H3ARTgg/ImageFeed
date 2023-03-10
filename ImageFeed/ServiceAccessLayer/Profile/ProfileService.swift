import Foundation
private enum Errors: String, Error {
    case failedToParseData = "Failed to parse data"
}

final class ProfileService {
    // MARK: Singleton and Properties
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private var lastCode: String?
    private(set) var profile: Profile?
    
    // MARK: - fetchProfile
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
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
                self.task = nil
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: profileResult.name,
                    bio: profileResult.bio
                )
                self.profile = profile
                completion(.success(profile))
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
}
