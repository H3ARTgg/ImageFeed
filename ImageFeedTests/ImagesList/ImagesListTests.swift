@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let view = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        view.presenter = presenterSpy
        presenterSpy.view = view
        
        // When
        _ = view.view
        
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testViewControllerCallsRequestPhotos() {
        // Given
        let view = ImagesListViewController()
        let presenter = ImagesListPresenter()
        let stub = StubImagesListService(isSuccessFetchPhotos: true,
                                         isSuccessChangeLike: false)
        presenter.imagesListService = stub
        presenter.view = view
        view.presenter = presenter
        
        // When
        _ = view.view
        
        // Then
        XCTAssertEqual(stub.photos.count, 10)
    }
    
    func testPresenterPhotosCount() {
        // Given
        let presenter = ImagesListPresenter()
        let stub = StubImagesListService(isSuccessFetchPhotos: true,
                                         isSuccessChangeLike: false)
        presenter.imagesListService = stub
        
        // When
        presenter.requestPhotos()
        
        // Then
        XCTAssertEqual(presenter.photosCount(), 10)
    }
    
    func testPresenterCallsPerfomBatchUpdates() {
        // Given
        let presenter = ImagesListPresenter()
        let sut = ImagesListViewControllerSpy()
        let stub = StubImagesListService(isSuccessFetchPhotos: true, isSuccessChangeLike: false)
        presenter.imagesListService = stub
        presenter.view = sut
        sut.presenter = presenter
        
        // When
        presenter.viewDidLoad()
        presenter.requestPhotos()
        
        // Then
        XCTAssertTrue(sut.isPerfomedBatchUpdates)
    }
    
    func testPresenterCallsReloadRow() {
        // Given
        let presenter = ImagesListPresenter()
        let sut = ImagesListViewControllerSpy()
        let stub = StubImagesListService(isSuccessFetchPhotos: true, isSuccessChangeLike: false)
        presenter.imagesListService = stub
        presenter.view = sut
        sut.presenter = presenter
        
        // When
        presenter.viewDidLoad()
        presenter.requestPhotos()
        presenter.updatePhotosImages(with: UIImage(), for: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertTrue(sut.isReloadedRow)
    }

}
