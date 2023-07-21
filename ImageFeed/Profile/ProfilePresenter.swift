import Foundation
import UIKit

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func showSplashViewController(presentBy: UIViewController)
    func avatarURL() -> URL?
}

final class ProfilePresenter: ProfilePresenterProtocol {
    private var profileImageServiceObserver: NSObjectProtocol?
    var profileService: ProfileServiceProtocol?
    var profileImageService: ProfileImageServiceProtocol?
    weak var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        if let profile = profileService?.profile {
            view?.updateProfileDetails(profile: profile)
        } else {
            print("failed to update profile")
        }
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.view?.updateAvatar()
            }
        view?.updateAvatar()
    }
    
    func showSplashViewController(presentBy: UIViewController) {
        let splashVC = SplashViewController()
        splashVC.firstTime = true
        splashVC.modalPresentationStyle = .fullScreen
        deleteTokenAndCleanWeb()
        presentBy.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.deleteTokenAndCleanWeb()
            presentBy.present(splashVC, animated: true)
        }
    }
    
    func avatarURL() -> URL? {
        guard let profileImageURL = profileImageService?.avatarURL,
              let url = URL(string: profileImageURL) else { return nil }
                return url
    }
    
    private func deleteTokenAndCleanWeb() {
        CleanWeb.shared.clean()
        TokenStorage.shared.removeToken()
    }
}
