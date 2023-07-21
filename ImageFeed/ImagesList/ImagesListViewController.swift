import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol? { get set }
    func showBasicError()
    func showAdvancedError()
    func perfomBatchUpdates(indexPaths: [IndexPath])
    func reloadRow(at indexPath: [IndexPath])
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol, AlertPresenterDelegate {
    // MARK: - Outlets and Properties
    @IBOutlet private var tableView: UITableView?
    var alertPresenter: AlertPresenterProtocol?
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        UIBlockingProgressHUD.show()
        presenter?.viewDidLoad()
        tableView?.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
    }
    
    func reloadRow(at indexPath: [IndexPath]) {
        tableView?.reloadRows(at: indexPath, with: .automatic)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
        presenter?.didTapLike(cell, with: indexPath) {
            UIBlockingProgressHUD.dismiss()
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let singleVC = presenter?.showSingleImageVC(indexPath: indexPath) else {
            assertionFailure("Can't create singleVC in didSelectRowAt")
            return
        }
        present(singleVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellHeight = presenter?.configHeight(tableView, with: indexPath) else {
            assertionFailure("No cell height")
            return 44
        }
        return cellHeight
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows, visibleIndexPaths.contains(indexPath) {
            guard let count = presenter?.photosCount() else {
                assertionFailure("No photos")
                return
            }
            
            if indexPath.row == count - 1 {
                UIBlockingProgressHUD.show()
                presenter?.requestPhotos()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = presenter?.photosCount() else {
            assertionFailure("No photos")
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            assertionFailure("Вышел else при касте до ImagesListCell в cellForRowAt(ImagesListViewController)")
            return UITableViewCell()
        }
        imageListCell.delegate = self // ImagesListCellDelegate
        imageListCell.isAccessibilityElement = true
        presenter?.configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
// MARK: - AlertPresenterDelegate
extension ImagesListViewController {
    func didRecieveAlertController(alert: UIAlertController?) {
        guard let alert = alert else {
            assertionFailure("No alert")
            return
        }
        present(alert, animated: true)
    }
}

// MARK: - perfomBatchUpdates, Errors
extension ImagesListViewController {
    func perfomBatchUpdates(indexPaths: [IndexPath]) {
        tableView?.performBatchUpdates {
            tableView?.insertRows(at: indexPaths, with: .automatic)
        }
        UIBlockingProgressHUD.dismiss()
    }
    
    func showBasicError() {
        UIBlockingProgressHUD.dismiss()
        let model = AlertModel(title: "Что-то пошло не так(", message: "Не удалось войти в систему", firstButtonText: "Ок", secondButtonText: nil, firstCompletion: nil, secondCompletion: nil)
        alertPresenter?.showBasic(model: model)
    }
    
    func showAdvancedError() {
        UIBlockingProgressHUD.dismiss()
        let model = AlertModel(title: "Что-то пошло не так(", message: "Попробовать ещё раз?", firstButtonText: "Не надо", secondButtonText: "Повторить") { [weak self] _ in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.presenter?.requestPhotos()
        } secondCompletion: { _ in }
        
        alertPresenter?.showAdvanced(model: model)
    }
}

