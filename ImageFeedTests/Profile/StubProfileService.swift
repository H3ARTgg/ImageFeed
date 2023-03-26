import Foundation
import ImageFeed

final class StubProfileService: ProfileServiceProtocol {
    var profile: Profile?
    var isSuccess: Bool = false
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        if !isSuccess {
            enum Errors: Error {
                case error
            }
            completion(.failure(Errors.error))
        } else {
            let profileResult = ProfileResult(username: "username", name: "name", bio: "bio")
            let profile = Profile(username: "username", name: "name", bio: "bio")
            self.profile = profile
            completion(.success(profileResult))
        }
    }
    
    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }
    
    
}
