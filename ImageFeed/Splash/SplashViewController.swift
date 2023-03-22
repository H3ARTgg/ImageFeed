import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    // MARK: - Properties
    private let oauth2Service = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var imageView = UIImageView()
    private var firstTime: Bool = true
    var isFromProfileVC: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFromProfileVC {
            showAuthVC()
            isFromProfileVC = false
        }
        
        guard firstTime == true else { return }
        if let token = KeychainWrapper.standard.string(forKey: TokenStorage.tokenKey) {
            UIBlockingProgressHUD.show()
            fetchProfile(token: token)
        } else {
            showAuthVC()
        }
        firstTime = false
    }
}

// MARK: - Extension(showAuthVC, switchToTabBarController)
extension SplashViewController {
    private func showAuthVC() {
        guard let authVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { return assertionFailure("Invalid Configuration") }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
    }
}

// MARK: - AuthViewControllerDelegat, ProfileService, ProfileImageService, Alert
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
                break
            }
        }
    }
    
    // ProfileService
    private func fetchProfile(token: String) {
        guard let token = KeychainWrapper.standard.string(forKey: TokenStorage.tokenKey) else { return }
        profileService.fetchProfile(token, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
                break
            case .success:
                if let profile = self.profileService.profile {
                    self.fetchProfileImage(username: profile.username ?? "")
                } else {
                    print("No profile")
                }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            }
        })
    }
    
    // ProfileImageService
    private func fetchProfileImage(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] _ in
            guard let self = self else { return }
            self.showErrorAlert()
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    // Alert
    private func showErrorAlert() {
        let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert
                )
                
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in
            alert.dismiss(animated: true)
        }
                
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - View configuration
extension SplashViewController {
    private func configureViews() {
        view.backgroundColor = .ypBlack
        imageView.image = UIImage(named: "splash_screen_logo")
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
    }
}
