import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var isPerfomedBatchUpdates: Bool = false
    var isReloadedRow: Bool = false
    
    func showBasicError() {}
    
    func showAdvancedError() {}
    
    func perfomBatchUpdates(indexPaths: [IndexPath]) {
        isPerfomedBatchUpdates = true
    }
    
    func reloadRow(at indexPath: [IndexPath]) {
        isReloadedRow = true
    }
}
