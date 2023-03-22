import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - Outlets and Properties
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageVC = "SingleImage"
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    private var photosImages: [UIImage] = []
    private var fullImageUrl: URL?
    private var imageViewForSingleImage = UIImageView()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        UIBlockingProgressHUD.show()
        imagesListService.fetchPhotosNextPage { [weak self] _ in
            guard let self = self else { return }
            self.showAdvancedError()
        }
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            })
    }
}

// MARK: - configCell, showSingleImageVC
extension ImagesListViewController {
    private func configHeight(with indexPath: IndexPath) -> CGFloat {
        let image = self.photosImages[indexPath.row]

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = self.tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let url = URL(string: photo.thumbImageURL)
        
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: url, placeholder: UIImage(named: "stub_photo"), options: .none) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.fullImageUrl = URL(string: photo.largeImageURL)
                self.photosImages.remove(at: indexPath.row)
                self.photosImages.insert(image.image, at: indexPath.row)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(_):
                print("failed to get image")
            }
        }
        
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.setIsLike(photo.isLiked)
    }
    
    private func showSingleImageVC(indexPath: IndexPath) {
        guard let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: showSingleImageVC) as? SingleImageViewController else { return }
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
        let photo = photos[indexPath.row]
        let url = URL(string: photo.largeImageURL)!
        
        UIBlockingProgressHUD.show()
        let imageViewForSingleImage = UIImageView()
        imageViewForSingleImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "stub_photo"),
            options: .none) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
                
            guard let self = self else { return }
            switch result {
            case .success(let image):
                viewController.image = image.image
            case .failure(let error):
                print(error)
                self.showAdvancedErrorForSVC(viewController)
            }
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.photos.remove(at: indexPath.row)
                self.photos.insert(self.imagesListService.photos[indexPath.row], at: indexPath.row)
                let newPhoto = self.photos[indexPath.row]
                cell.setIsLike(newPhoto.isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print(error)
                UIBlockingProgressHUD.dismiss()
                self.showBasicError()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImageVC(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight = configHeight(with: indexPath)
        return cellHeight
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            UIBlockingProgressHUD.show()
            imagesListService.fetchPhotosNextPage { [weak self] _ in
                guard let self = self else { return }
                self.showAdvancedError()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            print("Вышел else при касте до ImagesListCell в cellForRowAt(ImagesListViewController)")
            return UITableViewCell()
        }
        imageListCell.delegate = self // ImagesListCellDelegate
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: updateTableViewAnimated, Errors
extension ImagesListViewController {
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        // Добавление стоковых картинок
        for _ in oldCount..<newCount {
            photosImages.append(UIImage(named: "stub_photo")!)
        }
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func showBasicError() {
        let alert = ErrorAlert(viewController: self)
        alert.show()
    }
    
    private func showAdvancedError() {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        let dismissAction = UIAlertAction(title: "Не надо", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        let repeatAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.imagesListService.fetchPhotosNextPage(completion: { _ in
                self.showAdvancedError()
            })
        }
        
        alert.addAction(dismissAction)
        alert.addAction(repeatAction)
        self.present(alert, animated: true)
    }
    
    private func showAdvancedErrorForSVC(_ viewController: SingleImageViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        let dismissAction = UIAlertAction(title: "Не надо", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        
        let repeatAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.imageViewForSingleImage.kf.setImage(
                with: self.fullImageUrl,
                placeholder: UIImage(named: "stub_photo"),
                options: .none) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                    
                guard let self = self else { return }
                switch result {
                case .success(let image):
                    viewController.image = image.image
                    alert.dismiss(animated: true)
                case .failure(let error):
                    print(error)
                    alert.dismiss(animated: true)
                    self.showAdvancedErrorForSVC(viewController)
                }
            }
        }
        
        alert.addAction(dismissAction)
        alert.addAction(repeatAction)
        viewController.present(alert, animated: true)
    }
}

