import UIKit
import Kingfisher
import WebKit
import SwiftKeychainWrapper

private enum Errors: String {
    case imageError = "Не удалось получить картинку"
    case profileServiceError = "Не удалось получить профиль"
}

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var exitButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        configureImageView()
        configureExitButton()
        configureNameLabel()
        configureLoginLabel()
        configureDescriptionLabel()
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        } else {
            print("failed to update profile")
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    @objc private func didTapExit() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let splashVC = SplashViewController()
            splashVC.isFromProfileVC = true
            splashVC.modalPresentationStyle = .fullScreen
            self.dismiss(animated: true) {
                self.clean()
                TokenStorage.shared.removeToken()
                self.present(splashVC, animated: true)
            }
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
    
    private func clean() {
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          records.forEach { record in
             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
          }
       }
    }
}

// MARK: - updateAvatar
extension ProfileViewController {
    private func updateAvatar() {
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder_profile"),
            options: [.processor(processor)])
    }
}

// MARK: - updateProfilesDetails
extension ProfileViewController {
    private func updateProfileDetails(profile: Profile) {
        loginLabel.text = profile.loginName
        nameLabel.text = profile.name
        descriptionLabel.text = profile.bio
    }
}

// MARK: - Views Configuration
extension ProfileViewController {
    private func configureExitButton() {
        if let systemImage = UIImage(systemName: "ipad.and.arrow.forward") {
            exitButton = UIButton.systemButton(with: systemImage, target: self, action: #selector(didTapExit))
        } else {
            assertionFailure(Errors.imageError.rawValue)
        }
        
        exitButton.tintColor = UIColor(named: "YP Red")
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func configureImageView() {
        if let profileImage = UIImage(systemName: "person.crop.circle.fill") {
            imageView.image = profileImage
        }
        
        imageView.tintColor = .gray
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func configureNameLabel() {
        nameLabel.text = "Name"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = UIColor.ypWhite
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureLoginLabel() {
        loginLabel.text = "@login"
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.textColor = UIColor.ypGray
        
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        NSLayoutConstraint.activate([
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.text = "Some text"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor.ypWhite
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ])
    }
}
