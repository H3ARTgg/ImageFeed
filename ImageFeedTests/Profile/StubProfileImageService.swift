import ImageFeed

final class StubProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String?
    var isSuccess: Bool
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if isSuccess {
            let urlString = "test"
            self.avatarURL = urlString
            completion(.success(urlString))
        } else {
            enum Errors: Error {
                case error
            }
            completion(.failure(Errors.error))
        }
    }
    
    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }
}
