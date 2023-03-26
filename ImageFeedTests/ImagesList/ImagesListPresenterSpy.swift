import ImageFeed
import Foundation
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var imagesListService: ImagesListServiceProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func requestPhotos() {}
    
    func photosCount() -> Int { 10 }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) { }
    
    func showSingleImageVC(indexPath: IndexPath) -> UIViewController { UIViewController() }
    
    func didTapLike(_ cell: ImagesListCell, with indexPath: IndexPath, completion: @escaping () -> Void) {}
    
    func configHeight(_ tableView: UITableView, with indexPath: IndexPath) -> CGFloat { 15 }
}
