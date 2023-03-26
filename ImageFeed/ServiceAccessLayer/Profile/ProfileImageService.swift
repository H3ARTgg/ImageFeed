import Foundation

private enum URLError: Error {
    case noImages
}
public protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

final class ProfileImageService: ProfileImageServiceProtocol {
    // MARK: - Singleton and Properties
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    
    // MARK: - fetchProfileImageURL
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if task != nil {
            task?.cancel()
        }

        var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET")
        guard let token = TokenStorage.shared.token else {
            return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
                print(error)
                self.task = nil
            case .success(let profileImages):
                if let imagesURLs = profileImages.profileImage, let imageURL = imagesURLs["small"] {
                    completion(.success(imageURL))
                    self.avatarURL = imageURL
                    self.task = nil
                    NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self)
                } else {
                    completion(.failure(URLError.noImages))
                    self.task = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
}
