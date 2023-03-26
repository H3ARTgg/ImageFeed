@testable import ImageFeed
import Foundation
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        // Given
        let presenter = ProfilePresenter()
        let stubProfileService = StubProfileService(isSuccess: true)
        presenter.profileService = stubProfileService
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        viewController.presenter = presenter
        
        // When
        stubProfileService.fetchProfile("") { _ in }
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
    func testPresenterCallsUpdateProfileDetailes() {
        // Given
        let presenter = ProfilePresenter()
        let stubProfileService = StubProfileService(isSuccess: true)
        let viewController = ProfileViewControllerSpy()
        presenter.profileService = stubProfileService
        presenter.view = viewController
        
        // When
        stubProfileService.fetchProfile("") { _ in }
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(viewController.updateProfileDetailesCalled)
    }
    
    func testPresenterAvatarURL() {
        // Given
        let presenter = ProfilePresenter()
        let stub = StubProfileImageService(isSuccess: true)
        presenter.profileImageService = stub
        
        // When
        stub.fetchProfileImageURL(username: "") { _ in }
        let url = presenter.avatarURL()
        
        // Then
        XCTAssertEqual(url?.absoluteString, "test")
    }
}
