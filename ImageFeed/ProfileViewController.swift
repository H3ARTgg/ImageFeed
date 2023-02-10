import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    @objc func didTapExit() {
        
    }
    
    private func configureViews() {
        // ImageView
        let imageView = UIImageView()
        let profileImage = UIImage(systemName: "person.crop.circle.fill")
        imageView.image = profileImage
        imageView.tintColor = .gray
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Exit Button
        let exitButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(didTapExit))
        exitButton.tintColor = UIColor(named: "YP Red")
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        // Name Label
        let nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = UIColor.ypWhite
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        // Login Label
        let loginLabel = UILabel()
        loginLabel.text = "@login"
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.textColor = UIColor.ypGray
        
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        NSLayoutConstraint.activate([
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        // Description Label
        let descriptionLabel = UILabel()
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
