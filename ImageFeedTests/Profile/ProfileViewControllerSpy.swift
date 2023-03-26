import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var updateProfileDetailesCalled: Bool = false
    var updateAvatarCalled: Bool = false
    
    func updateProfileDetails(profile: Profile) {
        updateProfileDetailesCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
}
