import ImageFeed
import UIKit
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var showSplashCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func showSplashViewController(presentBy: UIViewController) {
        showSplashCalled = true
    }
    
    func avatarURL() -> URL? { return nil }
}
