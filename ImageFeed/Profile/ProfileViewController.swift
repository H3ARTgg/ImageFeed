import UIKit
import Kingfisher
import WebKit

private enum Errors: String {
    case imageError = "Не удалось получить картинку"
    case profileServiceError = "Не удалось получить профиль"
}

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(profile: Profile)
    func updateAvatar()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol, AlertPresenterDelegate {
    
    // MARK: - Properties
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var exitButton = UIButton()
    var presenter: ProfilePresenterProtocol?
    var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        configureImageView()
        configureExitButton()
        configureNameLabel()
        configureLoginLabel()
        configureDescriptionLabel()
        
        alertPresenter = AlertPresenter(delegate: self)
        presenter?.viewDidLoad()
    }
    
    @objc func didTapExit() {
        let model = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            firstButtonText: "Да",
            secondButtonText: "Нет") { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.showSplashViewController(presentBy: self)
            } secondCompletion: { _ in }

        alertPresenter?.showAdvanced(model: model)
    }
}
// MARK: - AlertPresenterDelegate
extension ProfileViewController {
    func didRecieveAlertController(alert: UIAlertController?) {
        guard let alert = alert else { return }
        present(alert, animated: true)
    }
}
// MARK: - updateProfilesDetails, updateAvatar
extension ProfileViewController {
    func updateProfileDetails(profile: Profile) {
        loginLabel.text = profile.loginName
        nameLabel.text = profile.name
        descriptionLabel.text = profile.bio
    }
    
    func updateAvatar() {
        let url = presenter?.avatarURL()
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder_profile"),
            options: [.processor(processor)])
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
        exitButton.accessibilityIdentifier = "exitButton"
        
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
