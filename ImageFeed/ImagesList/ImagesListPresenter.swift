import Foundation
import UIKit

public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesListService: ImagesListServiceProtocol? { get set }
    func viewDidLoad()
    func requestPhotos()
    func photosCount() -> Int
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func showSingleImageVC(indexPath: IndexPath) -> UIViewController
    func didTapLike(_ cell: ImagesListCell, with indexPath: IndexPath, completion: @escaping () -> Void)
    func configHeight(_ tableView: UITableView, with indexPath: IndexPath) -> CGFloat
}

protocol ImagesListCellPresenterDelegate {
    func updatePhotosImages(with image: UIImage, for indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol, ImagesListCellPresenterDelegate {
    private let showSingleImageVC = "SingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    private var photosImages: [UIImage] = []
    private var imageViewForSingleImage = UIImageView()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    var view: ImagesListViewControllerProtocol?
    var imagesListService: ImagesListServiceProtocol?
    
    func viewDidLoad() {
        imagesListService?.fetchPhotosNextPage { [weak self] _ in
            guard let self = self else { return }
            self.view?.showAdvancedError()
        }
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: imagesListService?.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self = self else { return }
                self.updateTableView()
            })
    }
    
    private func updateTableView() {
        guard let imagesListService = imagesListService else {
            assertionFailure("No imagesListService")
            return
        }
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        // Добавление стоковых картинок
        for _ in oldCount..<newCount {
            photosImages.append(UIImage(named: "stub_photo")!)
        }
        photos = imagesListService.photos
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            view?.perfomBatchUpdates(indexPaths: indexPaths)
        }
    }
    
    func photosCount() -> Int {
        return photos.count
    }
    
    func requestPhotos() {
        imagesListService?.fetchPhotosNextPage { [weak self] _ in
            guard let self = self else { return }
            self.view?.showAdvancedError()
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.presenterDelegate = self
        cell.configCell(with: photo, and: indexPath)
    }
    
    func updatePhotosImages(with image: UIImage, for indexPath: IndexPath) {
        photosImages[indexPath.row] = image
        view?.reloadRow(at: [indexPath])
    }
    
    func configHeight(_ tableView: UITableView, with indexPath: IndexPath) -> CGFloat {
        let image = photosImages[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func showSingleImageVC(indexPath: IndexPath) -> UIViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: showSingleImageVC) as? SingleImageViewController else {
            assertionFailure("No ViewController at that identifier")
            return UIViewController()
        }
        viewController.modalPresentationStyle = .fullScreen
        viewController.photo = photos[indexPath.row]
        return viewController
    }
    
    func didTapLike(_ cell: ImagesListCell, with indexPath: IndexPath, completion: @escaping () -> Void) {
        guard let imagesListService = imagesListService else {
            assertionFailure("No imagesListService")
            return
        }
        let photo = photos[indexPath.row]
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.photos[indexPath.row] = imagesListService.photos[indexPath.row]
                let newPhoto = self.photos[indexPath.row]
                cell.setIsLike(newPhoto.isLiked)
                completion()
            case .failure(let error):
                print(error)
                self.view?.showBasicError()
            }
        }
    }
}
